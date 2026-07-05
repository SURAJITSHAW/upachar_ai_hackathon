import 'package:flutter/material.dart';

import '../main.dart';
import '../theme/app_colors.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final strings = state.strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings.get('family'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final profile in state.profiles)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: profile.id == state.activeProfileId
                      ? AppColors.primary
                      : AppColors.primaryContainer,
                  child: Text(
                    profile.name.characters.first.toUpperCase(),
                    style: TextStyle(
                      color: profile.id == state.activeProfileId
                          ? Colors.white
                          : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHigh,
                  ),
                ),
                subtitle: Text(
                  '${profile.prescriptions.length} ${strings.get('medicines').toLowerCase()}',
                  style: const TextStyle(color: AppColors.textLow),
                ),
                trailing: profile.id == state.activeProfileId
                    ? const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                      )
                    : const Icon(Icons.chevron_right, color: AppColors.textLow),
                onTap: () => state.setActiveProfile(profile.id),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => showAddFamilyMemberDialog(context),
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
            label: Text(
              strings.get('addFamilyMember'),
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showAddFamilyMemberDialog(BuildContext context) async {
  final state = AppScope.of(context);
  final strings = state.strings;
  final controller = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(strings.get('addFamilyMember')),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: strings.get('name')),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(strings.get('cancel')),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) state.addProfile(name);
            Navigator.of(dialogContext).pop();
          },
          child: Text(strings.get('add')),
        ),
      ],
    ),
  );
}
