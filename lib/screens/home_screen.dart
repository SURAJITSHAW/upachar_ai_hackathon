import 'package:flutter/material.dart';

import '../main.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final strings = state.strings;
    final meds = state.todaysMedicines;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (!state.isOnline)
              Container(
                width: double.infinity,
                color: const Color(0xFFE5E5E5),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: 18,
                      color: AppColors.textHigh,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      strings.get('offlineBanner'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textHigh,
                      ),
                    ),
                  ],
                ),
              ),
            _AppBarRow(strings: strings),
            Expanded(
              child: meds.isEmpty
                  ? _EmptyState(strings: strings)
                  : _ScheduleTimeline(meds: meds),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarRow extends StatelessWidget {
  const _AppBarRow({required this.strings});

  final dynamic strings;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.get('appName'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              // Long-press to simulate going offline (demo helper).
              GestureDetector(
                onLongPress: () => state.setOnline(!state.isOnline),
                child: CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    state.activeProfile.name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  strings.get('todaysSchedule'),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHigh,
                    height: 1.1,
                  ),
                ),
              ),
              _ProfileSwitcher(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PopupMenuButton<String>(
      onSelected: state.setActiveProfile,
      itemBuilder: (context) => [
        for (final p in state.profiles)
          PopupMenuItem(value: p.id, child: Text(p.name)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textLow.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.activeProfile.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textHigh,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textHigh),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.strings});

  final dynamic strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              strings.get('emptyStateTitle'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textHigh,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.get('emptyStateSubtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: AppColors.textLow),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.arrow_downward,
              size: 36,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTimeline extends StatelessWidget {
  const _ScheduleTimeline({required this.meds});

  final List<Medicine> meds;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: meds.length,
      itemBuilder: (context, i) => _MedicineCard(medicine: meds[i]),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({required this.medicine});

  final Medicine medicine;

  bool get _dueNow {
    final now = TimeOfDay.now();
    final match = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)',
    ).firstMatch(medicine.time);
    if (match == null) return false;
    var h = int.parse(match.group(1)!);
    if (h == 12) h = 0;
    if (match.group(3) == 'PM') h += 12;
    final medMinutes = h * 60 + int.parse(match.group(2)!);
    final nowMinutes = now.hour * 60 + now.minute;
    return !medicine.taken &&
        nowMinutes >= medMinutes &&
        nowMinutes - medMinutes < 120;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final strings = state.strings;
    final due = _dueNow;
    final highlighted = due && !medicine.taken;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 8),
            child: Icon(
              medicine.taken
                  ? Icons.radio_button_checked
                  : due
                  ? Icons.circle
                  : Icons.radio_button_unchecked,
              size: 18,
              color: medicine.taken || due
                  ? AppColors.primary
                  : AppColors.textLow.withValues(alpha: 0.5),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: highlighted ? AppColors.primaryContainer : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: AppColors.textLow,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${medicine.time} - ${medicine.timeLabel}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textLow,
                          ),
                        ),
                      ),
                      if (medicine.taken)
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                        )
                      else if (due)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            strings.get('dueNow'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHigh,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${medicine.name} ${medicine.dosage}'.trim(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: medicine.taken
                          ? AppColors.textLow
                          : AppColors.textHigh,
                      decoration: medicine.taken
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${medicine.quantity} • ${medicine.route}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textLow,
                    ),
                  ),
                  if (due && !medicine.taken) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => state.toggleTaken(medicine),
                      icon: const Icon(Icons.check),
                      label: Text(strings.get('takeNow')),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
