import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_strings.dart';
import '../main.dart';
import '../theme/app_colors.dart';
import 'home_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpStage = false;
  bool _sending = false;
  String? _phoneError;
  String? _otpError;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool get _phoneValid =>
      RegExp(r'^[6-9]\d{9}$').hasMatch(_phoneController.text.trim());

  Future<void> _sendOtp() async {
    final strings = AppScope.of(context).strings;
    if (!_phoneValid) {
      setState(() => _phoneError = strings.get('invalidMobile'));
      return;
    }
    setState(() {
      _phoneError = null;
      _sending = true;
    });

    // Simulated OTP API call with a chance of network failure.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (Random().nextInt(10) == 0) {
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.get('networkError')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _sending = false;
      _otpStage = true;
      _otpError = null;
      _otpController.clear();
    });
    _startResendCountdown();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _resendSeconds--);
      if (_resendSeconds <= 0) t.cancel();
    });
  }

  Future<void> _verifyOtp() async {
    // Demo build: verification is client-side and only "000000" passes.
    if (_otpController.text.trim() != '000000') {
      setState(
        () => _otpError =
            'Invalid verification code. For demo purposes, please use 000000.',
      );
      return;
    }
    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    await AppScope.of(context).login('+91 ${_phoneController.text.trim()}');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.get('appName')),
        leading: _otpStage
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textHigh),
                onPressed: () => setState(() => _otpStage = false),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.get('secureLogin'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHigh,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: AppColors.textHigh),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings.get('dataEncrypted'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textHigh,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (!_otpStage)
                ..._phoneStage(strings)
              else
                ..._otpStageUi(strings),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _phoneStage(AppStrings strings) {
    return [
      Text(
        strings.get('mobileNumber'),
        style: const TextStyle(fontSize: 16, color: AppColors.textHigh),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 20, letterSpacing: 1.5),
        decoration: InputDecoration(
          counterText: '',
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Text(
              '+91',
              style: TextStyle(fontSize: 20, color: AppColors.textHigh),
            ),
          ),
          errorText: _phoneError,
          suffixIcon: _phoneError != null
              ? const Icon(Icons.error_outline, color: AppColors.error)
              : null,
        ),
        onChanged: (_) {
          if (_phoneError != null) setState(() => _phoneError = null);
        },
      ),
      const SizedBox(height: 32),
      ElevatedButton(
        onPressed: _sending ? null : _sendOtp,
        child: _sending
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(strings.get('sendOtp')),
      ),
    ];
  }

  List<Widget> _otpStageUi(AppStrings strings) {
    return [
      Text(
        strings.get('enterOtp'),
        style: const TextStyle(fontSize: 18, color: AppColors.textHigh),
      ),
      const SizedBox(height: 4),
      Text(
        '${strings.get('otpSentTo')} +91 ${_phoneController.text}',
        style: const TextStyle(fontSize: 15, color: AppColors.textLow),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        autofocus: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 28, letterSpacing: 12),
        decoration: InputDecoration(counterText: '', errorText: _otpError),
        onChanged: (_) {
          if (_otpError != null) setState(() => _otpError = null);
        },
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: _sending ? null : _verifyOtp,
        child: _sending
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(strings.get('verify')),
      ),
      const SizedBox(height: 16),
      Center(
        child: _resendSeconds > 0
            ? Text(
                '${strings.get('resendIn')} 0:${_resendSeconds.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16, color: AppColors.textLow),
              )
            : TextButton(
                onPressed: () {
                  _sendOtp();
                },
                child: Text(
                  strings.get('resendOtp'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
      ),
    ];
  }
}
