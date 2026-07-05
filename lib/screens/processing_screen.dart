import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';
import '../services/ai_service.dart';
import '../theme/app_colors.dart';
import 'details_screen.dart';

/// Shimmer skeleton + rotating status text while the AI pipeline runs.
/// After 10s a "processing locally" notice appears; failures show a
/// Try Again button.
class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  final _ai = AiService();
  int _messageIndex = 0;
  bool _slow = false;
  bool _failed = false;
  bool _modelWaking = false;
  String? _errorMessage;
  Timer? _messageTimer;
  Timer? _slowTimer;
  Timer? _wakeRetryTimer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    setState(() {
      _failed = false;
      _slow = false;
      _modelWaking = false;
      _errorMessage = null;
      _messageIndex = 0;
    });
    _messageTimer?.cancel();
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) setState(() => _messageIndex = (_messageIndex + 1) % 3);
    });
    _slowTimer?.cancel();
    _slowTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => _slow = true);
    });
    _run();
  }

  Future<void> _run() async {
    try {
      final result = await _ai.analyze(widget.imagePath);
      if (!mounted) return;
      if (result.processedLocally) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppScope.of(context).strings.get('processedLocally')),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DetailsScreen(prescription: result.prescription),
        ),
      );
    } on ModelWakingUpException {
      // HF 503 cold start: broadcast the waking state and retry shortly.
      if (!mounted) return;
      setState(() => _modelWaking = true);
      _wakeRetryTimer?.cancel();
      _wakeRetryTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) _run();
      });
    } on LocalAiUnavailableException catch (e) {
      // Ollama not reachable: show its specific "start the daemon" message.
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _failed = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _shimmer.dispose();
    _messageTimer?.cancel();
    _slowTimer?.cancel();
    _wakeRetryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    final messages = [
      strings.get('processing1'),
      strings.get('processing2'),
      strings.get('processing3'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _failed
              ? _failedView(strings)
              : Column(
                  children: [
                    const SizedBox(height: 24),
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(
                        Icons.psychology_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        _modelWaking
                            ? strings.get('modelWaking')
                            : _slow
                            ? strings.get('processingSlow')
                            : messages[_messageIndex],
                        key: ValueKey('$_modelWaking$_slow$_messageIndex'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _modelWaking || _slow
                              ? AppColors.warning
                              : AppColors.textHigh,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.primaryContainer,
                    ),
                    const SizedBox(height: 40),
                    _SkeletonBox(controller: _shimmer, height: 120),
                    const SizedBox(height: 16),
                    _SkeletonBox(controller: _shimmer, height: 160),
                    const SizedBox(height: 16),
                    _SkeletonBox(controller: _shimmer, height: 80),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(strings.get('cancel')),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _failedView(dynamic strings) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
        const SizedBox(height: 16),
        Text(
          _errorMessage ?? strings.get('networkError'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: AppColors.textHigh),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _start, child: Text(strings.get('tryAgain'))),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.get('cancel')),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.controller, required this.height});

  final AnimationController controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(0 + 2 * t, 0),
              colors: const [
                Color(0xFFF0F0F0),
                Color(0xFFE6E6E6),
                Color(0xFFF0F0F0),
              ],
            ),
          ),
        );
      },
    );
  }
}
