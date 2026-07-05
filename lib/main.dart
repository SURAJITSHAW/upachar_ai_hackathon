import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/splash_screen.dart';
import 'services/app_state.dart';
import 'services/tts_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(UpacharApp(appState: AppState(prefs)));
}

class UpacharApp extends StatelessWidget {
  const UpacharApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: appState,
      tts: TtsService(),
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, _) => MaterialApp(
          title: 'Upachar AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

/// Exposes [AppState] and [TtsService] to the widget tree and rebuilds
/// dependents when state changes.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required this.tts,
    required super.child,
  }) : super(notifier: state);

  final TtsService tts;

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static TtsService ttsOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.tts;
}
