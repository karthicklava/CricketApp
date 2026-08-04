import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
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

  test('iOS includes an opaque 1024 point marketing icon', () {
    final icon = img.decodePng(File(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
    ).readAsBytesSync())!;
    expect((icon.width, icon.height), (1024, 1024));
    expect(icon.every((pixel) => pixel.a == 255), isTrue);
  });
}
