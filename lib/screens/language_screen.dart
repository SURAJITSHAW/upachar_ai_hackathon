import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../main.dart';
import '../theme/app_colors.dart';
import 'auth_screen.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key, this.fromSettings = false});

  /// When opened from Settings we just pop back instead of continuing
  /// the onboarding flow.
  final bool fromSettings;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final strings = state.strings;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 48),
              const CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.health_and_safety,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                strings.get('appName'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  strings.get('tagline'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.get('welcome'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHigh,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.get('selectLanguage'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textLow,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final lang in AppLanguage.values) ...[
                      _LanguageTile(
                        language: lang,
                        onTap: () async {
                          await state.setLanguage(lang);
                          if (!context.mounted) return;
                          if (fromSettings) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const AuthScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE3FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.textHigh,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              strings.get('languageChangeHint'),
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textHigh,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.language, required this.onTap});

  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryContainer.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Text(
                  language.shortLabel,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                language.displayName,
                style: const TextStyle(fontSize: 20, color: AppColors.textHigh),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
