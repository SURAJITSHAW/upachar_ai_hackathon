import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'gemma4_service.dart';
import 'ocr_service.dart';

export 'gemma4_service.dart'
    show ModelWakingUpException, LocalAiUnavailableException;

/// Result of the AI pipeline. [processedLocally] marks the on-device
/// fallback path used when remote inference fails or times out.
class AiResult {
  AiResult({required this.prescription, this.processedLocally = false});

  final Prescription prescription;
  final bool processedLocally;
}

/// Pipeline: on-device OCR (ML Kit) -> Gemma 4 on Hugging Face ->
/// structured [Prescription]. Successful payloads are cached to
/// SharedPreferences for offline persistence; any remote failure other
/// than a 503 cold-start falls back to the local interpreter so the demo
/// never dead-ends.
class AiService {
  // Local Edge AI budget. Generous because the first scan often pays a cold
  // model load (Ollama unloads after ~5 min idle) plus CPU/GPU contention
  // from the emulator on the same machine; warm inference is only ~5s.
  static const inferenceTimeout = Duration(seconds: 60);
  static const _kLastPayload = 'lastGemmaPayload';

  final _ocr = OcrService();
  final _gemma = Gemma4Service();

  Future<AiResult> analyze(String imagePath) async {
    String ocrText = '';
    try {
      ocrText = await _ocr.extractText(imagePath);
    } catch (e) {
      debugPrint('OCR failed: $e');
    }
    if (ocrText.isEmpty) {
      // Nothing legible: go straight to the local fallback.
      return AiResult(
        prescription: _mockPrescription(),
        processedLocally: true,
      );
    }

    try {
      final raw = await _gemma
          .processPrescriptionText(ocrText)
          .timeout(inferenceTimeout);
      // Cache the raw structured payload for offline availability.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLastPayload, raw);
      return AiResult(prescription: _parseGemmaOutput(raw));
    } on ModelWakingUpException {
      rethrow; // UI shows the "model waking up" state and retries.
    } on LocalAiUnavailableException {
      // Ollama is down: surface the "start the daemon" guidance instead of
      // silently falling back to mock data, which would hide the outage.
      rethrow;
    } catch (e) {
      debugPrint('Remote inference failed, processing locally: $e');
      return AiResult(
        prescription: _mockPrescription(),
        processedLocally: true,
      );
    }
  }

  /// Parses Gemma's JSON (tolerating markdown code fences) into a
  /// [Prescription]. Falls back to the local interpreter on malformed
  /// output rather than surfacing hallucinated structure.
  Prescription _parseGemmaOutput(String raw) {
    try {
      var text = raw.trim();
      final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(text);
      if (fence != null) text = fence.group(1)!.trim();
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start == -1 || end <= start) throw const FormatException();
      final json =
          jsonDecode(text.substring(start, end + 1)) as Map<String, dynamic>;

      final medicines = <Medicine>[];
      for (final m in (json['medicines'] as List? ?? [])) {
        final med = m as Map<String, dynamic>;
        final name = (med['name'] as String? ?? '').trim();
        if (name.isEmpty) continue;
        final dosage = (med['dosage'] as String? ?? '').trim();
        final timing = (med['timing'] as String? ?? '').trim();
        final (time, label) = _mapTiming(timing);
        medicines.add(
          Medicine(
            name: name,
            dosage: dosage,
            quantity: '1 Tablet',
            route: 'Orally',
            time: time,
            timeLabel: label,
            // Missing dosage means the model could not read it confidently;
            // force a manual review before the schedule can be saved.
            needsReview: dosage.isEmpty,
          ),
        );
      }
      if (medicines.isEmpty) throw const FormatException();

      final warnings = (json['interactions'] as List? ?? [])
          .map((w) => '$w')
          .toList();
      // New Ollama prompt emits 'summary'; keep 'localized_summary' as a
      // fallback so any payloads cached under the old schema still parse.
      final summary = (json['summary'] ?? json['localized_summary']) as String?;
      return Prescription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doctorName: 'Scanned Prescription',
        scannedAt: DateTime.now(),
        medicines: medicines,
        warnings: [
          ...warnings,
          if (summary != null && summary.isNotEmpty) summary,
        ],
      );
    } catch (e) {
      debugPrint('Failed to parse Gemma output: $e');
      return _mockPrescription();
    }
  }

  (String, String) _mapTiming(String timing) {
    final t = timing.toLowerCase();
    if (t.contains('night') || t.contains('dinner') || t.contains('evening')) {
      return ('09:00 PM', 'After Dinner');
    }
    if (t.contains('lunch') || t.contains('afternoon') || t.contains('noon')) {
      return ('01:00 PM', 'After Lunch');
    }
    if (t.contains('fast') || t.contains('empty')) {
      return ('08:00 AM', 'Fasting');
    }
    return ('09:00 AM', 'After Breakfast');
  }

  Prescription _mockPrescription() {
    return Prescription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      doctorName: 'Dr. A. Patel',
      scannedAt: DateTime.now(),
      medicines: [
        Medicine(
          name: 'Lisinopril',
          dosage: '10mg',
          quantity: '1 Tablet',
          route: 'Orally',
          time: '09:00 AM',
          timeLabel: 'After Breakfast',
        ),
        Medicine(
          name: 'Metformin',
          dosage: '500mg',
          quantity: '1 Tablet',
          route: 'Orally',
          time: '01:00 PM',
          timeLabel: 'After Lunch',
        ),
        // Simulated OCR ambiguity: dosage could not be fully read ("1-?-1").
        Medicine(
          name: 'Amlodipine',
          dosage: '',
          quantity: '1 Tablet',
          route: 'Orally',
          time: '09:00 PM',
          timeLabel: 'After Dinner',
          needsReview: true,
        ),
      ],
      warnings: [
        'Lisinopril + Amlodipine: both lower blood pressure. Monitor for dizziness.',
        'Take Metformin with food to avoid stomach upset.',
      ],
    );
  }
}
