import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

const densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];
const iosFiles = {
  'Icon-App-20x20@1x.png': 20,
  'Icon-App-20x20@2x.png': 40,
  'Icon-App-20x20@3x.png': 60,
  'Icon-App-29x29@1x.png': 29,
  'Icon-App-29x29@2x.png': 58,
  'Icon-App-29x29@3x.png': 87,
  'Icon-App-40x40@1x.png': 40,
  'Icon-App-40x40@2x.png': 80,
  'Icon-App-40x40@3x.png': 120,
  'Icon-App-60x60@2x.png': 120,
  'Icon-App-60x60@3x.png': 180,
  'Icon-App-76x76@1x.png': 76,
  'Icon-App-76x76@2x.png': 152,
  'Icon-App-83.5x83.5@2x.png': 167,
  'Icon-App-1024x1024@1x.png': 1024,
};

void main() {
  test('exactly Jersey 1 through 99 are packaged and registered', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    for (var number = 1; number <= 99; number++) {
      expect(manifest, contains('android:name=".MainActivityJersey$number"'));
      expect(manifest, contains('android:icon="@mipmap/jersey_$number"'));
      expect(plist, contains('<key>Jersey$number</key>'));
      for (final density in densities) {
        expect(File('android/app/src/main/res/mipmap-$density/jersey_$number.png')
            .existsSync(), isTrue);
        expect(File('android/app/src/main/res/drawable-$density/jersey_${number}_foreground.png')
            .existsSync(), isTrue);
        expect(File('android/app/src/main/res/drawable-$density/jersey_${number}_monochrome.png')
            .existsSync(), isTrue);
      }
      final iosSet =
          Directory('ios/Runner/Assets.xcassets/Jersey$number.appiconset');
      for (final expected in iosFiles.entries) {
        final decoded = img.decodeImage(
            File('${iosSet.path}/${expected.key}').readAsBytesSync());
        expect(decoded, isNotNull);
        expect(decoded!.width, expected.value);
        expect(decoded.height, expected.value);
      }
    }
    expect(RegExp(r'MainActivityJersey\d+').allMatches(manifest), hasLength(99));
    expect(RegExp('android:enabled="true"').allMatches(manifest), hasLength(1));
    expect(RegExp('android:enabled="false"').allMatches(manifest), hasLength(99));
    expect(manifest, isNot(contains('MainActivityJersey0')));
    expect(manifest, isNot(contains('MainActivityJersey100')));
    expect(plist, isNot(contains('<key>Jersey0</key>')));
    expect(plist, isNot(contains('<key>Jersey100</key>')));
  });

  test('adaptive foreground is transparent, safe, and separate from preview', () {
    final foregroundFile = File(
        'android/app/src/main/res/drawable-xxxhdpi/jersey_18_foreground.png');
    final foreground = img.decodePng(foregroundFile.readAsBytesSync())!;
    final preview = File('assets/branding/launcher_previews/jersey_18.png');
    expect(foreground.width, 432);
    expect(foreground.height, 432);
    expect(foreground.getPixel(0, 0).a, 0);
    final unsafePixels = foreground.where((pixel) =>
        pixel.a > 12 &&
        (pixel.x < 52 || pixel.y < 52 || pixel.x >= 380 || pixel.y >= 380));
    expect(unsafePixels, isEmpty);
    expect(preview.path, isNot(foregroundFile.path));
    expect(File('android/app/src/main/res/mipmap-anydpi-v26/jersey_18.xml')
        .readAsStringSync(), contains('@drawable/jersey_18_monochrome'));
  });

  test('native mappings use the same normalized names', () {
    final android = File(
            'android/app/src/main/kotlin/com/example/cricket_scorer/MainActivity.kt')
        .readAsStringSync();
    expect(android, contains('MainActivityJersey'));
    expect(android, contains('for (number in 1..99)'));
    final ios = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    expect(ios, contains('"Jersey" + jersey'));
    expect(ios, contains(r'^Jersey([1-9]|[1-9][0-9])$'));
  });
}
