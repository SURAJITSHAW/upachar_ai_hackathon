import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_healthcare/main.dart';
import 'package:ai_healthcare/services/app_state.dart';

void main() {
  testWidgets('Splash screen renders app name', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(UpacharApp(appState: AppState(prefs)));
    expect(find.text('Upachar AI'), findsOneWidget);
    // Let the splash timer finish so the test ends cleanly.
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
