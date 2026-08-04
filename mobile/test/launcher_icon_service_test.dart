import 'package:cricket_scorer/core/services/launcher_icon_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/launcher_icon');
  late SharedPreferences preferences;
  final calls = <MethodCall>[];

  Future<void> prepare([Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    preferences = await SharedPreferences.getInstance();
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
  }

  setUp(prepare);
  tearDown(() => TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));

  test('supports exactly 1 through 99 and removes leading zeroes', () {
    expect(LauncherIconService.minimumJerseyNumber, 1);
    expect(LauncherIconService.maximumJerseyNumber, 99);
    expect(LauncherIconService.normalizeJerseyNumber('1'), '1');
    expect(LauncherIconService.normalizeJerseyNumber('07'), '7');
    expect(LauncherIconService.normalizeJerseyNumber('99'), '99');
    for (final invalid in [
      '0',
      '00',
      '100',
      '1000',
      '-1',
      '1.5',
      'A',
      '#7',
      ''
    ]) {
      expect(() => LauncherIconService.normalizeJerseyNumber(invalid),
          throwsFormatException,
          reason: '$invalid must be rejected');
    }
  });

  test('boundary icon IDs map consistently and persist as integers', () async {
    final service = LauncherIconService(preferences, channel: channel);
    expect(LauncherIconService.iconIdFor('1'), 'jersey_1');
    expect(LauncherIconService.iconIdFor('99'), 'jersey_99');
    final result = await service.applyJerseyIcon('18');
    expect(result.iconId, 'jersey_18');
    expect(calls.single.method, 'setLauncherIcon');
    expect(calls.single.arguments['jerseyNumber'], '18');
    expect(preferences.getInt(LauncherIconService.selectedJerseyNumberKey), 18);
    expect(preferences.getBool(LauncherIconService.launcherIconAppliedKey),
        isTrue);
  });

  test('native failure saves badge choice but not applied state', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => false);
    final result = await LauncherIconService(preferences, channel: channel)
        .applyJerseyIcon('45');
    expect(result.success, isFalse);
    expect(preferences.getInt(LauncherIconService.selectedJerseyNumberKey), 45);
    expect(preferences.getBool(LauncherIconService.launcherIconAppliedKey),
        isNot(true));
  });

  test('invalid old preference restores default and requests selection',
      () async {
    await prepare({
      LauncherIconService.selectedJerseyNumberKey: '1000',
      LauncherIconService.selectedLauncherIconIdKey: 'jersey_1000',
      LauncherIconService.launcherIconAppliedKey: true,
    });
    final migrated = await LauncherIconService(preferences, channel: channel)
        .normalizePersistedState();
    expect(migrated, isTrue);
    expect(calls.single.method, 'normalizeLauncherState');
    expect(calls.single.arguments['iconId'], isNull);
    expect(
        preferences.get(LauncherIconService.selectedJerseyNumberKey), isNull);
    expect(preferences.getBool(LauncherIconService.launcherIconAppliedKey),
        isFalse);
    expect(
        preferences.getBool(LauncherIconService.launcherIconMigrationPromptKey),
        isTrue);
  });

  test('fresh install stays on default without migration warning', () async {
    final migrated =
        await LauncherIconService(preferences, channel: channel)
            .normalizePersistedState();
    expect(migrated, isFalse);
    expect(preferences.getBool(
        LauncherIconService.launcherIconMigrationPromptKey), isNot(true));
  });

  test('valid selection survives restart normalization', () async {
    await prepare({
      LauncherIconService.selectedJerseyNumberKey: 88,
      LauncherIconService.selectedLauncherIconIdKey: 'jersey_88',
      LauncherIconService.launcherIconAppliedKey: true,
    });
    final migrated = await LauncherIconService(preferences, channel: channel)
        .normalizePersistedState();
    expect(migrated, isFalse);
    expect(preferences.getInt(LauncherIconService.selectedJerseyNumberKey), 88);
  });

  test('restore default preserves profile jersey choice', () async {
    await preferences.setInt(LauncherIconService.selectedJerseyNumberKey, 18);
    final result = await LauncherIconService(preferences, channel: channel)
        .restoreDefaultIcon();
    expect(result.success, isTrue);
    expect(calls.single.method, 'restoreDefaultIcon');
    expect(preferences.getInt(LauncherIconService.selectedJerseyNumberKey), 18);
    expect(preferences.getBool(LauncherIconService.launcherIconAppliedKey),
        isFalse);
  });
}
