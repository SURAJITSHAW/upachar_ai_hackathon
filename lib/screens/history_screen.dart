import 'package:flutter/material.dart';

import '../main.dart';
import '../theme/app_colors.dart';
import 'details_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final strings = state.strings;
    final prescriptions = state.activeProfile.prescriptions.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: Text(strings.get('history'))),
      body: prescriptions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history,
                      size: 64,
                      color: AppColors.textLow,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.get('noHistory'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textLow,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prescriptions.length,
              itemBuilder: (context, i) {
                final p = prescriptions[i];
                final date =
                    '${p.scannedAt.day.toString().padLeft(2, '0')}/${p.scannedAt.month.toString().padLeft(2, '0')}/${p.scannedAt.year}';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(Icons.receipt_long, color: AppColors.primary),
                    ),
                    title: Text(
                      p.doctorName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHigh,
                      ),
                    ),
                    subtitle: Text(
                      '$date • ${p.medicines.length} ${strings.get('medicines')}',
                      style: const TextStyle(color: AppColors.textLow),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textLow,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DetailsScreen(prescription: p, alreadySaved: true),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
