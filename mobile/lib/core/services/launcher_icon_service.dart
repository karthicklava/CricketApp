import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LauncherIconResult {
  final bool success;
  final String? iconId;
  final String? error;

  const LauncherIconResult._(this.success, {this.iconId, this.error});
  const LauncherIconResult.success(String? iconId)
      : this._(true, iconId: iconId);
  const LauncherIconResult.failure(String error) : this._(false, error: error);
}

class LauncherIconService {
  static const int minimumJerseyNumber = 1;
  static const int maximumJerseyNumber = 99;
  static const channelName = 'cricket_scorer/launcher_icon';
  static const _defaultChannel = MethodChannel(channelName);

  static const selectedJerseyNumberKey = 'selectedJerseyNumber';
  static const selectedLauncherIconIdKey = 'selectedLauncherIconId';
  static const launcherIconAppliedKey = 'launcherIconApplied';
  static const launcherIconAppliedAtKey = 'launcherIconAppliedAt';
  static const launcherIconPlatformKey = 'launcherIconPlatform';
  static const launcherIconLastErrorKey = 'launcherIconLastError';
  static const launcherIconMigrationPromptKey = 'launcherIconMigrationPrompt';

  final SharedPreferences preferences;
  final MethodChannel channel;

  LauncherIconService(this.preferences, {MethodChannel? channel})
      : channel = channel ?? _defaultChannel;

  static int parseJerseyNumber(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Enter a jersey number.');
    }
    if (!RegExp(r'^\d{1,2}$').hasMatch(trimmed)) {
      throw const FormatException(
          'Enter a valid whole number between 1 and 99.');
    }
    final value = int.parse(trimmed);
    if (value < minimumJerseyNumber) {
      throw const FormatException('Jersey number must be between 1 and 99.');
    }
    if (value > maximumJerseyNumber) {
      throw const FormatException(
          'Only jersey numbers from 1 to 99 are currently supported.');
    }
    return value;
  }

  static String normalizeJerseyNumber(String input) =>
      '${parseJerseyNumber(input)}';

  static String iconIdFor(String jerseyNumber) =>
      'jersey_${parseJerseyNumber(jerseyNumber)}';

  Future<bool> isSupported() async {
    try {
      return await channel.invokeMethod<bool>('isSupported') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<LauncherIconResult> applyJerseyIcon(String jerseyNumber) async {
    late final int number;
    try {
      number = parseJerseyNumber(jerseyNumber);
    } on FormatException catch (error) {
      return LauncherIconResult.failure(error.message);
    }
    final display = '$number';
    final iconId = iconIdFor(display);
    // The user's jersey choice is independent from whether the operating
    // system accepts the launcher icon change.
    await preferences.setInt(selectedJerseyNumberKey, number);
    try {
      final applied = await channel.invokeMethod<bool>(
            'setLauncherIcon',
            {'iconId': iconId, 'jerseyNumber': display},
          ) ??
          false;
      if (!applied) {
        return _recordFailure('Native platform did not apply $iconId.');
      }
      await preferences.setString(selectedLauncherIconIdKey, iconId);
      await preferences.setBool(launcherIconAppliedKey, true);
      await preferences.setInt(
          launcherIconAppliedAtKey, DateTime.now().millisecondsSinceEpoch);
      await preferences.setString(launcherIconPlatformKey, _platformName);
      await preferences.remove(launcherIconLastErrorKey);
      return LauncherIconResult.success(iconId);
    } on PlatformException catch (error) {
      return _recordFailure(error.message ?? error.code);
    } catch (error) {
      return _recordFailure(error.toString());
    }
  }

  Future<LauncherIconResult> restoreDefaultIcon() async {
    try {
      final restored =
          await channel.invokeMethod<bool>('restoreDefaultIcon') ?? false;
      if (!restored) {
        return _recordFailure('Native platform did not restore the icon.');
      }
      await preferences.remove(selectedLauncherIconIdKey);
      await preferences.setBool(launcherIconAppliedKey, false);
      await preferences.setInt(
          launcherIconAppliedAtKey, DateTime.now().millisecondsSinceEpoch);
      await preferences.setString(launcherIconPlatformKey, _platformName);
      await preferences.remove(launcherIconLastErrorKey);
      return const LauncherIconResult.success(null);
    } on PlatformException catch (error) {
      return _recordFailure(error.message ?? error.code);
    } catch (error) {
      return _recordFailure(error.toString());
    }
  }

  Future<String?> getSelectedIcon() async {
    try {
      final native = await channel.invokeMethod<String>('getSelectedIcon');
      if (native != null && native.isNotEmpty && native != 'default') {
        return native;
      }
      return null;
    } catch (_) {
      return preferences.getString(selectedLauncherIconIdKey);
    }
  }

  Future<bool> normalizePersistedState() async {
    final rawNumber = preferences.get(selectedJerseyNumberKey);
    final rawIcon = preferences.getString(selectedLauncherIconIdKey);
    final wasApplied = preferences.getBool(launcherIconAppliedKey) ?? false;
    if (rawNumber == null && rawIcon == null && !wasApplied) {
      try {
        await channel.invokeMethod<bool>(
            'normalizeLauncherState', {'iconId': null});
      } catch (_) {}
      return false;
    }
    final parsed = rawNumber is int
        ? rawNumber
        : rawNumber is String
            ? int.tryParse(rawNumber)
            : null;
    final validNumber = parsed != null &&
        parsed >= minimumJerseyNumber &&
        parsed <= maximumJerseyNumber;
    final expectedIcon = validNumber ? 'jersey_$parsed' : null;
    final validAppliedState = rawIcon == null || rawIcon == expectedIcon;
    try {
      await channel.invokeMethod<bool>('normalizeLauncherState', {
        'iconId': validAppliedState ? rawIcon : null,
      });
    } catch (_) {
      // Persistence is still normalized even if the current platform cannot
      // switch icons. The UI will report unsupported status separately.
    }
    if (!validNumber || !validAppliedState) {
      await preferences.remove(selectedJerseyNumberKey);
      await preferences.remove(selectedLauncherIconIdKey);
      await preferences.setBool(launcherIconAppliedKey, false);
      await preferences.setBool(launcherIconMigrationPromptKey, true);
      return true;
    }
    if (rawNumber is String) {
      await preferences.setInt(selectedJerseyNumberKey, parsed);
    }
    return false;
  }

  Future<LauncherIconResult> _recordFailure(String message) async {
    await preferences.setString(launcherIconLastErrorKey, message);
    return LauncherIconResult.failure(message);
  }

  String get _platformName {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return Platform.operatingSystem;
  }
}
