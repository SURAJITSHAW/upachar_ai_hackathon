import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../main.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import 'home_shell.dart';

/// Structured AI output: medicines / schedule / warnings tabs, TTS
/// playback, inline editing to correct OCR mistakes, and amber
/// highlighting for fields the model could not read confidently.
class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    super.key,
    required this.prescription,
    this.alreadySaved = false,
  });

  final Prescription prescription;
  final bool alreadySaved;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final strings = state.strings;
    final tts = AppScope.ttsOf(context);
    final p = widget.prescription;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.get('prescriptionDetails')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textHigh),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textLow,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: strings.get('medicines')),
              Tab(text: strings.get('schedule')),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(strings.get('warnings')),
                    if (p.warnings.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: AppColors.warning,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // TTS player; hidden entirely if the engine failed to init.
            if (tts.available)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ValueListenableBuilder<bool>(
                  valueListenable: tts.speaking,
                  builder: (context, speaking, _) => Material(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => speaking
                          ? tts.stop()
                          : tts.speak(
                              _summaryText(strings),
                              state.language ?? AppLanguage.english,
                            ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(
                              speaking
                                  ? Icons.stop_circle_outlined
                                  : Icons.volume_up_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              speaking
                                  ? strings.get('stopAudio')
                                  : strings.get('listenAloud'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  _medicinesTab(strings),
                  _scheduleTab(strings),
                  _warningsTab(strings),
                ],
              ),
            ),
            if (!widget.alreadySaved)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _hasUnresolvedReview ? null : _save,
                  icon: const Icon(Icons.check),
                  label: Text(strings.get('saveSchedule')),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get _hasUnresolvedReview =>
      widget.prescription.medicines.any((m) => m.needsReview);

  String _summaryText(AppStrings strings) {
    final meds = widget.prescription.medicines
        .map(
          (m) =>
              '${m.name} ${m.dosage}, ${m.quantity}, ${m.time} ${m.timeLabel}.',
        )
        .join(' ');
    final warnings = widget.prescription.warnings.join(' ');
    return '$meds $warnings';
  }

  Future<void> _save() async {
    final state = AppScope.of(context);
    final strings = state.strings;
    await state.addPrescription(widget.prescription);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.get('prescriptionSaved')),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (route) => false,
    );
  }

  Widget _medicinesTab(AppStrings strings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.prescription.medicines.length,
      itemBuilder: (context, i) {
        final m = widget.prescription.medicines[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: m.needsReview
                ? const BorderSide(color: AppColors.warning, width: 2)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${m.name} ${m.dosage}'.trim(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHigh,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: strings.get('editMedicine'),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                      ),
                      onPressed: () => _editMedicine(m),
                    ),
                  ],
                ),
                Text(
                  '${m.quantity} • ${m.route} • ${m.time} (${m.timeLabel})',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textLow,
                  ),
                ),
                if (m.needsReview) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          size: 18,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strings.get('needsReview'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textHigh,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _scheduleTab(AppStrings strings) {
    final meds = [...widget.prescription.medicines];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meds.length,
      itemBuilder: (context, i) {
        final m = meds[i];
        return ListTile(
          leading: const Icon(Icons.access_time, color: AppColors.primary),
          title: Text(
            '${m.time} - ${m.timeLabel}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textHigh,
            ),
          ),
          subtitle: Text(
            '${m.name} ${m.dosage} • ${m.quantity}'.trim(),
            style: const TextStyle(color: AppColors.textLow),
          ),
        );
      },
    );
  }

  Widget _warningsTab(AppStrings strings) {
    if (widget.prescription.warnings.isEmpty) {
      return const Center(
        child: Icon(
          Icons.check_circle_outline,
          size: 64,
          color: AppColors.success,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.prescription.warnings.length,
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.prescription.warnings[i],
                style: const TextStyle(fontSize: 16, color: AppColors.textHigh),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editMedicine(Medicine medicine) async {
    final state = AppScope.of(context);
    final strings = state.strings;
    final nameController = TextEditingController(text: medicine.name);
    final dosageController = TextEditingController(text: medicine.dosage);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.get('editMedicine')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: strings.get('medicines')),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage',
                hintText: 'e.g. 5mg',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.get('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.get('save')),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;
    setState(() {
      medicine.name = nameController.text.trim();
      medicine.dosage = dosageController.text.trim();
      // Reviewing counts as resolving the ambiguity if a dosage was set.
      if (medicine.dosage.isNotEmpty) medicine.needsReview = false;
    });
    if (widget.alreadySaved) await state.updateMedicine();
  }
}
