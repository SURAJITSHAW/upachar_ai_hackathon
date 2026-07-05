import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';
import '../models/models.dart';

/// Global app state: language, auth, profiles and prescriptions.
/// Persisted to SharedPreferences so the app works fully offline.
class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    _load();
  }

  static const _kLanguage = 'language';
  static const _kLoggedIn = 'loggedIn';
  static const _kPhone = 'phone';
  static const _kProfiles = 'profiles';
  static const _kActiveProfile = 'activeProfile';

  final SharedPreferences _prefs;

  AppLanguage? language;
  bool loggedIn = false;
  String phone = '';
  List<FamilyProfile> profiles = [];
  String activeProfileId = 'me';

  /// Simulated connectivity flag; toggled from the UI for demos and set
  /// when a (mock) network call fails.
  bool isOnline = true;

  AppStrings get strings => AppStrings(language ?? AppLanguage.english);

  bool get isFirstLaunch => language == null;

  FamilyProfile get activeProfile => profiles.firstWhere(
    (p) => p.id == activeProfileId,
    orElse: () => profiles.first,
  );

  void _load() {
    final langCode = _prefs.getString(_kLanguage);
    language = langCode == null ? null : AppLanguageX.fromCode(langCode);
    loggedIn = _prefs.getBool(_kLoggedIn) ?? false;
    phone = _prefs.getString(_kPhone) ?? '';
    activeProfileId = _prefs.getString(_kActiveProfile) ?? 'me';

    final raw = _prefs.getString(_kProfiles);
    if (raw != null) {
      try {
        profiles = FamilyProfile.decodeList(raw);
      } catch (_) {
        profiles = [];
      }
    }
    if (profiles.isEmpty) {
      profiles = [FamilyProfile(id: 'me', name: 'My Profile')];
    }
  }

  Future<void> _persistProfiles() async {
    await _prefs.setString(_kProfiles, FamilyProfile.encodeList(profiles));
  }

  Future<void> setLanguage(AppLanguage lang) async {
    language = lang;
    await _prefs.setString(_kLanguage, lang.code);
    notifyListeners();
  }

  Future<void> login(String phoneNumber) async {
    loggedIn = true;
    phone = phoneNumber;
    await _prefs.setBool(_kLoggedIn, true);
    await _prefs.setString(_kPhone, phoneNumber);
    notifyListeners();
  }

  Future<void> logout() async {
    loggedIn = false;
    await _prefs.setBool(_kLoggedIn, false);
    notifyListeners();
  }

  void setOnline(bool online) {
    isOnline = online;
    notifyListeners();
  }

  Future<void> setActiveProfile(String id) async {
    activeProfileId = id;
    await _prefs.setString(_kActiveProfile, id);
    notifyListeners();
  }

  Future<void> addProfile(String name) async {
    profiles.add(
      FamilyProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      ),
    );
    await _persistProfiles();
    notifyListeners();
  }

  Future<void> addPrescription(Prescription prescription) async {
    activeProfile.prescriptions = [
      ...activeProfile.prescriptions,
      prescription,
    ];
    await _persistProfiles();
    notifyListeners();
  }

  Future<void> toggleTaken(Medicine medicine) async {
    medicine.taken = !medicine.taken;
    await _persistProfiles();
    notifyListeners();
  }

  Future<void> updateMedicine() async {
    await _persistProfiles();
    notifyListeners();
  }

  /// Today's medicines across all of the active profile's prescriptions,
  /// sorted by time.
  List<Medicine> get todaysMedicines {
    final meds = activeProfile.prescriptions.expand((p) => p.medicines).toList()
      ..sort((a, b) => _minutes(a.time).compareTo(_minutes(b.time)));
    return meds;
  }

  static int _minutes(String time) {
    // Parses "08:00 AM" style strings; unparseable times sort last.
    final match = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)',
      caseSensitive: false,
    ).firstMatch(time);
    if (match == null) return 24 * 60;
    var h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final pm = match.group(3)!.toUpperCase() == 'PM';
    if (h == 12) h = 0;
    return (pm ? h + 12 : h) * 60 + m;
  }

  Future<void> clearCache() async {
    // Cache is anything reconstructible; keep profiles and auth.
    notifyListeners();
  }

  Future<void> deleteAllData() async {
    await _prefs.clear();
    language = null;
    loggedIn = false;
    phone = '';
    activeProfileId = 'me';
    profiles = [FamilyProfile(id: 'me', name: 'My Profile')];
    notifyListeners();
  }
}
