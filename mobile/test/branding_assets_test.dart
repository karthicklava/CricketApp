import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('platform display names use TurfScore without changing identifiers', () {
    final androidManifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final iosInfo = File('ios/Runner/Info.plist').readAsStringSync();
    final webManifest = File('web/manifest.json').readAsStringSync();
    final androidBuild =
        File('android/app/build.gradle.kts').readAsStringSync();
    final iosProject =
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

    expect(androidManifest, contains('android:label="TurfScore"'));
    expect(iosInfo, contains('<string>TurfScore</string>'));
    expect(webManifest, contains('"name": "TurfScore"'));
    expect(webManifest, contains('"short_name": "TurfScore"'));
    expect(
        androidBuild, contains('applicationId = "com.example.cricket_scorer"'));
    expect(iosProject,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.example.cricketScorer;'));
  });

  test('master icon and transparent brand mark are production sized', () {
    final icon = img.decodePng(
      File('assets/branding/cricket_scorer_icon_1024.png').readAsBytesSync(),
    )!;
    final mark = img.decodePng(
      File('assets/branding/cricket_scorer_mark.png').readAsBytesSync(),
    )!;

    expect((icon.width, icon.height), (1024, 1024));
    expect((mark.width, mark.height), (1024, 1024));
    expect(mark.getPixel(0, 0).a, 0);
    expect(icon.getPixel(0, 0).a, 255);
  });

  test('default icon remains cricket-recognizable at mdpi launcher size', () {
    final icon = img.decodePng(
      File('android/app/src/main/res/mipmap-mdpi/ic_launcher.png')
          .readAsBytesSync(),
    )!;
    expect((icon.width, icon.height), (48, 48));

    // The hero bat and ball produce a substantial high-contrast white region
    // through the icon centre instead of being confined to the bottom edge.
    final heroPixels = icon.where((pixel) =>
        pixel.x >= 12 &&
        pixel.x <= 35 &&
        pixel.y >= 10 &&
        pixel.y <= 36 &&
        pixel.r > 205 &&
        pixel.g > 205 &&
        pixel.b > 185);
    expect(heroPixels.length, greaterThan(45));
  });

  test('branding pipeline never relies on low-resolution or JPEG sources', () {
    final jerseyGenerator =
        File('tool/generate_jersey_launcher_icons.dart').readAsStringSync();
    final brandGenerator =
        File('tool/generate_brand_assets.dart').readAsStringSync();
    final brandingFiles = Directory('assets/branding')
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => file.path.toLowerCase());

    expect(jerseyGenerator, isNot(contains('arial48')));
    expect(jerseyGenerator, isNot(contains('quantize(')));
    expect(jerseyGenerator, isNot(contains('_digitSegments')));
    expect(jerseyGenerator, contains('_drawAthleticDigit'));
    expect(jerseyGenerator, contains('previewSize\': 512'));
    expect(brandGenerator,
        contains('assets/branding/cricket_scorer_mark_chroma.png'));
    expect(brandGenerator, contains('Jersey variants intentionally use'));
    expect(brandGenerator, isNot(contains('launcher_previews/jersey_')));
    expect(brandGenerator, contains('_transparentLayer(1024'));
    expect(
      brandingFiles
          .any((path) => path.endsWith('.jpg') || path.endsWith('.jpeg')),
      isFalse,
    );
  });

  test('Android launcher supplies adaptive and themed icon layers', () {
    final adaptive = File(
      'android/app/src/main/res/mipmap-anydpi-v33/ic_launcher.xml',
    ).readAsStringSync();
    expect(adaptive, contains('ic_launcher_foreground'));
    expect(adaptive, contains('ic_launcher_monochrome'));
    expect(adaptive, contains('launcher_background'));

    const expectedSizes = {
      'mdpi': 108,
      'hdpi': 162,
      'xhdpi': 216,
      'xxhdpi': 324,
      'xxxhdpi': 432,
    };
    for (final entry in expectedSizes.entries) {
      final foreground = img.decodePng(File(
        'android/app/src/main/res/mipmap-${entry.key}/ic_launcher_foreground.png',
      ).readAsBytesSync())!;
      expect(foreground.width, entry.value);
      expect(foreground.height, entry.value);
    }
  });

  test('native splash uses a high-resolution transparent logo', () {
    final splash = img.decodePng(File(
      'android/app/src/main/res/drawable-nodpi/brand_splash_logo.png',
    ).readAsBytesSync())!;
    expect((splash.width, splash.height), (1024, 1024));
    expect(splash.getPixel(0, 0).a, 0);
  });

  test('iOS includes an opaque 1024 point marketing icon', () {
    final icon = img.decodePng(File(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
    ).readAsBytesSync())!;
    expect((icon.width, icon.height), (1024, 1024));
    expect(icon.every((pixel) => pixel.a == 255), isTrue);
  });
}
