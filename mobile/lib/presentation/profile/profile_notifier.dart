import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_state.dart';
import '../../main.dart';
import '../../core/services/launcher_icon_service.dart';

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ProfileNotifier(prefs);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final SharedPreferences _prefs;

  static const _keyUserName = 'profile_user_name';
  static const _keyJerseyDisplay = 'profile_jersey_display';
  static const _keyJerseyVal = 'profile_jersey_val';
  static const _keyStyle = 'profile_icon_style';
  static const _keyColor = 'profile_primary_color';
  static const _keyPdfPrivacy = 'profile_include_in_pdf';

  ProfileNotifier(this._prefs) : super(ProfileState.defaultProfile()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final name = _prefs.getString(_keyUserName) ?? 'Guest Scorer';
    final storedDisplay = _prefs.getString(_keyJerseyDisplay) ?? '18';
    final storedValue =
        _prefs.getInt(_keyJerseyVal) ?? int.tryParse(storedDisplay) ?? 18;
    final val = storedValue >= 1 && storedValue <= 99 ? storedValue : 18;
    final display = '$val';
    if (val != storedValue || display != storedDisplay) {
      _prefs.setString(_keyJerseyDisplay, display);
      _prefs.setInt(_keyJerseyVal, val);
    }
    final styleName = _prefs.getString(_keyStyle) ?? 'shield';
    final color = _prefs.getString(_keyColor) ?? '#0D6EFD';
    final pdfPrivacy = _prefs.getBool(_keyPdfPrivacy) ?? false;

    CricketIconStyle style = CricketIconStyle.shield;
    try {
      style = CricketIconStyle.values.firstWhere((e) => e.name == styleName);
    } catch (_) {}

    state = ProfileState(
      userName: name,
      jerseyNumberDisplay: display,
      jerseyNumberValue: val,
      iconStyle: style,
      primaryColorHex: color,
      includeProfileInPdf: pdfPrivacy,
    );
  }

  Future<void> updateProfile({
    required String userName,
    required String jerseyNumberDisplay,
    required CricketIconStyle iconStyle,
    required String primaryColorHex,
    required bool includeProfileInPdf,
  }) async {
    final normalized =
        LauncherIconService.normalizeJerseyNumber(jerseyNumberDisplay);
    final val = int.parse(normalized);

    state = ProfileState(
      userName: userName.trim(),
      jerseyNumberDisplay: normalized,
      jerseyNumberValue: val,
      iconStyle: iconStyle,
      primaryColorHex: primaryColorHex,
      includeProfileInPdf: includeProfileInPdf,
    );

    await _prefs.setString(_keyUserName, state.userName);
    await _prefs.setString(_keyJerseyDisplay, state.jerseyNumberDisplay);
    await _prefs.setInt(_keyJerseyVal, state.jerseyNumberValue);
    await _prefs.setString(_keyStyle, state.iconStyle.name);
    await _prefs.setString(_keyColor, state.primaryColorHex);
    await _prefs.setBool(_keyPdfPrivacy, state.includeProfileInPdf);
  }

  Future<void> setPdfPrivacy(bool value) async {
    state = state.copyWith(includeProfileInPdf: value);
    await _prefs.setBool(_keyPdfPrivacy, value);
  }

  Future<void> resetToDefault() async {
    state = ProfileState.defaultProfile();
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyJerseyDisplay);
    await _prefs.remove(_keyJerseyVal);
    await _prefs.remove(_keyStyle);
    await _prefs.remove(_keyColor);
    await _prefs.remove(_keyPdfPrivacy);
  }
}
