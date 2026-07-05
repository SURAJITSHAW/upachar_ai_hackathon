import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Thrown on HTTP 503: the model is cold-starting on the provider and the
/// UI should broadcast a "model waking up" state, then retry.
class ModelWakingUpException implements Exception {}

/// Thrown when the local Ollama server cannot be reached (connection
/// refused). Carries a ready-to-display [message] so the UI can prompt the
/// operator to start the daemon rather than silently degrading.
class LocalAiUnavailableException implements Exception {
  LocalAiUnavailableException(this.message);

  final String message;

  @override
  String toString() => 'LocalAiUnavailableException: $message';
}

/// Edge-AI client for a local [Ollama](https://ollama.com) server.
///
/// Talks to Ollama's OpenAI-compatible chat-completions endpoint over plain
/// HTTP on the loopback interface — no cloud round-trip and no API token, so
/// prescription text never leaves the machine.
///
/// Host resolution differs per platform: the Android emulator runs on its
/// own virtual network where `localhost` points at the emulator itself, so
/// the host Mac is reached through the documented `10.0.2.2` alias. The iOS
/// Simulator (and desktop builds) share the host network, so `localhost`
/// resolves directly.
class Gemma4Service {
  static const String _model = 'gemma2:2b';

  /// Extractor contract. The `response_format: json_object` flag enforces
  /// well-formed JSON at the API layer; this prompt pins the schema and
  /// suppresses the chit-chat small local models tend to add.
  static const String _systemPrompt =
      'You are a medical data extractor. You must output ONLY valid JSON '
      "containing 'medicines', 'interactions', and 'summary'. Do not include "
      'markdown formatting, greetings, explanations, or any other text.';

  /// Ollama's OpenAI-compatible endpoint.
  ///
  /// A USB-attached Android phone can't reach the Mac's network directly, and
  /// `10.0.2.2` is an emulator-only alias — so the device loopback is tunnelled
  /// to the host with an adb reverse, run once per session:
  ///   adb reverse tcp:11434 tcp:11434
  /// That maps device `localhost:11434` -> Mac `localhost:11434` (and works for
  /// emulators too). The iOS Simulator and desktop builds share the host
  /// network, so the same address resolves directly.
  static const String _endpoint = 'http://127.0.0.1:11434/v1/chat/completions';

  Future<String> processPrescriptionText(String rawOcrText) async {
    final requestBody = {
      'model': _model,
      // Force structured output at the transport layer, not just via the
      // prompt, so the downstream parser can trust it receives valid JSON.
      'response_format': {'type': 'json_object'},
      // Deterministic extraction — zero creativity so the model never
      // invents a medicine or dosage that was not on the prescription.
      'temperature': 0.0,
      'stream': false,
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {
          'role': 'user',
          // The system prompt fixes the top-level keys; this reiterates the
          // per-medicine shape the parser expects (name / dosage / timing).
          'content':
              'Extract the medication data from this prescription text. Each '
              'entry in "medicines" must be an object with "name", "dosage" '
              'and "timing" fields.\n\nPrescription text:\n$rawOcrText',
        },
      ],
    };

    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 60));
    } on SocketException {
      // Connection refused: the Ollama daemon isn't listening on :11434.
      throw LocalAiUnavailableException(
        'Cannot connect to local AI. Ensure Ollama is running.',
      );
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>;
      final message =
          (choices.first as Map<String, dynamic>)['message']
              as Map<String, dynamic>;
      return (message['content'] as String?)?.trim() ?? '';
    } else if (response.statusCode == 503) {
      throw ModelWakingUpException();
    } else {
      debugPrint(
        'Gemma Service Error: HTTP ${response.statusCode} ${response.body}',
      );
      throw Exception(
        'Server responded with status code: ${response.statusCode}',
      );
    }
  }
}
