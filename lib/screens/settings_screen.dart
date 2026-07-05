import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../main.dart';
import '../theme/app_colors.dart';
import 'family_screen.dart';
import 'language_screen.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final strings = state.strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings.get('appName'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            strings.get('settings'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textHigh,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.get('settingsSubtitle'),
            style: const TextStyle(fontSize: 16, color: AppColors.textLow),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: strings.get('profiles')),
          Card(
            child: Column(
              children: [
                for (final profile in state.profiles) ...[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: profile.id == state.activeProfileId
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      child: Text(
                        profile.id == state.activeProfileId
                            ? 'Me'
                            : profile.name.characters.first.toUpperCase(),
                        style: TextStyle(
                          color: profile.id == state.activeProfileId
                              ? Colors.white
                              : AppColors.textLow,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      profile.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHigh,
                      ),
                    ),
                    subtitle: profile.id == state.activeProfileId
                        ? Text(
                            strings.get('active'),
                            style: const TextStyle(color: AppColors.textLow),
                          )
                        : null,
                    trailing: profile.id == state.activeProfileId
                        ? const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.primary,
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: AppColors.textLow,
                          ),
                    onTap: () => state.setActiveProfile(profile.id),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                ],
                ListTile(
                  leading: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    strings.get('addFamilyMember'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => showAddFamilyMemberDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: strings.get('preferences')),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: AppColors.textHigh,
                  ),
                  title: Text(
                    strings.get('languageSelection'),
                    style: const TextStyle(color: AppColors.textHigh),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (state.language ?? AppLanguage.english) ==
                                AppLanguage.english
                            ? 'English'
                            : (state.language == AppLanguage.bengali
                                  ? 'বাংলা'
                                  : 'हिंदी'),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textLow,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textLow),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LanguageScreen(fromSettings: true),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textHigh,
                  ),
                  title: Text(
                    strings.get('notificationSettings'),
                    style: const TextStyle(color: AppColors.textHigh),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textLow,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: strings.get('dataPrivacy')),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.download_outlined,
                    color: AppColors.textHigh,
                  ),
                  title: Text(
                    strings.get('exportHealthData'),
                    style: const TextStyle(color: AppColors.textHigh),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textLow,
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(
                    Icons.cleaning_services_outlined,
                    color: AppColors.textHigh,
                  ),
                  title: Text(
                    strings.get('clearCache'),
                    style: const TextStyle(color: AppColors.textHigh),
                  ),
                  onTap: () async {
                    await state.clearCache();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.get('cacheCleared'))),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever_outlined,
                    color: AppColors.error,
                  ),
                  title: Text(
                    strings.get('deleteAllData'),
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => _confirmDeleteAll(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: strings.get('about')),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppColors.textHigh,
                  ),
                  title: Text(
                    strings.get('appVersion'),
                    style: const TextStyle(color: AppColors.textHigh),
                  ),
                  trailing: const Text(
                    'v1.2.4',
                    style: TextStyle(fontSize: 15, color: AppColors.textLow),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(
                    Icons.help_outline,
                    color: AppColors.textHigh,
                  ),
                  title: Text(
                    strings.get('support'),
                    style: const TextStyle(color: AppColors.textHigh),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textLow,
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.textHigh),
                  title: Text(
                    strings.get('logout'),
                    style: const TextStyle(color: AppColors.textHigh),
                  ),
                  onTap: () async {
                    await state.logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final state = AppScope.of(context);
    final strings = state.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.get('deleteAllData')),
        content: Text(strings.get('deleteAllConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.get('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.get('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await state.deleteAllData();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: AppColors.textLow,
        ),
      ),
    );
  }
}
