import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const minimumJerseyNumber = 1;
const maximumJerseyNumber = 99;
const _androidManifest = 'android/app/src/main/AndroidManifest.xml';
const _iosPlist = 'ios/Runner/Info.plist';
const _xcodeProject = 'ios/Runner.xcodeproj/project.pbxproj';
// This production-sized transparent PNG is the single raster master for every
// jersey launcher surface. It is never generated from a Flutter preview.
const _foregroundMaster = 'assets/branding/launcher_shield_foreground.png';

const _androidLegacySizes = <String, int>{
  'mdpi': 48,
  'hdpi': 72,
  'xhdpi': 96,
  'xxhdpi': 144,
  'xxxhdpi': 192,
};
const _androidAdaptiveSizes = <String, int>{
  'mdpi': 108,
  'hdpi': 162,
  'xhdpi': 216,
  'xxhdpi': 324,
  'xxxhdpi': 432,
};
const _iosSizes = <String, int>{
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
  _removeOldGeneratedAssets();
  final foregroundMaster =
      img.decodeImage(File(_foregroundMaster).readAsBytesSync());
  if (foregroundMaster == null) {
    throw StateError('Unable to decode $_foregroundMaster');
  }
  if (foregroundMaster.width < 1024 || foregroundMaster.height < 1024) {
    throw StateError('Launcher master must be at least 1024 x 1024.');
  }
  final appIconContents =
      File('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json')
          .readAsStringSync();
  final aliases = StringBuffer()..writeln(_defaultAlias);
  final plistIcons = StringBuffer()
    ..writeln('\t<key>CFBundleIcons</key>')
    ..writeln('\t<dict><key>CFBundleAlternateIcons</key><dict>');

  for (var number = minimumJerseyNumber;
      number <= maximumJerseyNumber;
      number++) {
    final display = '$number';
    final foreground = _numberedForeground(foregroundMaster, display);
    _validateSafeArea(foreground, display);
    final legacy = _legacyIcon(foreground);
    final monochrome = _monochrome(foreground);

    _writePng('assets/branding/launcher_previews/jersey_$display.png',
        _resize(legacy, 512));
    for (final size in _androidLegacySizes.entries) {
      _writePng(
          'android/app/src/main/res/mipmap-${size.key}/jersey_$display.png',
          _resize(legacy, size.value));
    }
    for (final size in _androidAdaptiveSizes.entries) {
      _writePng(
          'android/app/src/main/res/drawable-${size.key}/jersey_${display}_foreground.png',
          _resize(foreground, size.value));
      _writePng(
          'android/app/src/main/res/drawable-${size.key}/jersey_${display}_monochrome.png',
          _resize(monochrome, size.value));
    }
    File('android/app/src/main/res/mipmap-anydpi-v26/jersey_$display.xml')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(_adaptiveXml(display));
    aliases.writeln(_androidAlias(display));

    final iosSet =
        Directory('ios/Runner/Assets.xcassets/Jersey$display.appiconset')
          ..createSync(recursive: true);
    File('${iosSet.path}/Contents.json').writeAsStringSync(appIconContents);
    for (final size in _iosSizes.entries) {
      _writePng('${iosSet.path}/${size.key}', _resize(legacy, size.value));
    }
    plistIcons.writeln(_plistIcon(display));
  }
  plistIcons.writeln('\t</dict></dict>');

  _replaceGeneratedSection(
      File(_androidManifest),
      '<!-- GENERATED_LAUNCHER_ALIASES_START -->',
      '<!-- GENERATED_LAUNCHER_ALIASES_END -->',
      aliases.toString());
  _replaceGeneratedSection(
      File(_iosPlist),
      '<!-- GENERATED_ALTERNATE_ICONS_START -->',
      '<!-- GENERATED_ALTERNATE_ICONS_END -->',
      plistIcons.toString());
  _updateXcodeAlternateNames();
  File('assets/branding/launcher_icon_inventory.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
    'minimum': minimumJerseyNumber,
    'maximum': maximumJerseyNumber,
    'variantCount': 99,
    'style': 'shield',
    'nativeSourceSize': foregroundMaster.width,
    'previewSize': 512,
    'masterAsset': _foregroundMaster,
    'previewIsNativeSource': false,
  }));
}

void _removeOldGeneratedAssets() {
  final iosRoot = Directory('ios/Runner/Assets.xcassets');
  for (final entry in iosRoot.listSync()) {
    if (entry is Directory &&
        RegExp(r'/Jersey\d+\.appiconset$').hasMatch(entry.path)) {
      entry.deleteSync(recursive: true);
    }
  }
  final roots = <Directory>[
    Directory('assets/branding/launcher_previews'),
    Directory('android/app/src/main/res/mipmap-anydpi-v26'),
    ..._androidLegacySizes.keys.map(
        (density) => Directory('android/app/src/main/res/mipmap-$density')),
    ..._androidAdaptiveSizes.keys.map(
        (density) => Directory('android/app/src/main/res/drawable-$density')),
    Directory('android/app/src/main/res/drawable-nodpi'),
  ];
  for (final root in roots) {
    if (!root.existsSync()) continue;
    for (final entry in root.listSync()) {
      final name = entry.uri.pathSegments.last;
      if (RegExp(r'^(icon|jersey)_\d+(_foreground|_monochrome)?\.(png|xml)$')
          .hasMatch(name)) {
        entry.deleteSync(recursive: true);
      }
    }
  }
}

img.Image _numberedForeground(img.Image shield, String display) {
  final output = img.Image(width: 1024, height: 1024, numChannels: 4);
  final safeShield = img.copyResize(shield,
      width: 760, height: 760, interpolation: img.Interpolation.average);
  img.compositeImage(output, safeShield, dstX: 132, dstY: 132);

  // Render each jersey digit directly at the 1024px production resolution.
  // This avoids the previous 48px bitmap-font upscale, which was the primary
  // source of blurred and jagged personalized icons.
  final shadow = _jerseyNumberLayer(display, img.ColorRgba8(38, 71, 52, 210));
  final number =
      _jerseyNumberLayer(display, img.ColorRgba8(252, 251, 244, 255));
  img.compositeImage(output, shadow, dstX: 7, dstY: 9);
  img.compositeImage(output, number);
  return output;
}

img.Image _jerseyNumberLayer(String value, img.Color color) {
  final layer = img.Image(width: 1024, height: 1024, numChannels: 4);
  final scale = value.length == 1 ? 1.20 : .88;
  final digitWidth = (160 * scale).round();
  final digitHeight = (260 * scale).round();
  final gap = value.length == 1 ? 0 : 26;
  final totalWidth = value.length * digitWidth + (value.length - 1) * gap;
  final startX = (1024 - totalWidth) ~/ 2;
  final startY = value.length == 1 ? 302 : 340;

  for (var index = 0; index < value.length; index++) {
    _drawAthleticDigit(
      layer,
      value[index],
      startX + index * (digitWidth + gap),
      startY,
      scale,
      color,
    );
  }
  return layer;
}

void _drawAthleticDigit(img.Image layer, String digit, int x, int y,
    double scale, img.Color color) {
  final clear = img.ColorRgba8(0, 0, 0, 0);
  int sx(num value) => x + (value * scale).round();
  int sy(num value) => y + (value * scale).round();
  void polygon(List<(num, num)> points, img.Color fill) => img.fillPolygon(
        layer,
        vertices: points
            .map((point) => img.Point(sx(point.$1), sy(point.$2)))
            .toList(),
        color: fill,
        blend: fill.a == 0 ? img.BlendMode.direct : img.BlendMode.alpha,
      );
  void roundedRect(
      num left, num top, num right, num bottom, num radius, img.Color fill) {
    // Transparent rounded fills are alpha-blended as no-ops by package:image.
    // Clear counters directly; their squared inner corners suit the athletic
    // block style while the outer silhouette retains subtle rounding.
    img.fillRect(layer,
        x1: sx(left),
        y1: sy(top),
        x2: sx(right),
        y2: sy(bottom),
        radius: fill.a == 0 ? 0 : radius * scale,
        color: fill,
        alphaBlend: fill.a != 0);
  }

  switch (digit) {
    case '0':
      roundedRect(5, 0, 155, 260, 22, color);
      roundedRect(52, 45, 108, 215, 10, clear);
      break;
    case '1':
      polygon([
        (18, 53),
        (80, 0),
        (126, 0),
        (126, 215),
        (153, 215),
        (153, 260),
        (36, 260),
        (36, 215),
        (78, 215),
        (78, 61),
        (45, 86)
      ], color);
      break;
    case '2':
      polygon([
        (8, 42),
        (38, 5),
        (126, 5),
        (153, 34),
        (153, 102),
        (57, 214),
        (153, 214),
        (153, 260),
        (8, 260),
        (8, 204),
        (106, 91),
        (106, 55),
        (98, 48),
        (55, 48),
        (55, 82),
        (8, 82)
      ], color);
      break;
    case '3':
      polygon([
        (8, 5),
        (125, 5),
        (153, 33),
        (153, 101),
        (126, 130),
        (153, 158),
        (153, 230),
        (124, 260),
        (8, 260),
        (8, 215),
        (101, 215),
        (107, 207),
        (107, 159),
        (99, 151),
        (53, 151),
        (53, 108),
        (99, 108),
        (107, 99),
        (107, 57),
        (100, 49),
        (8, 49)
      ], color);
      break;
    case '4':
      polygon([
        (8, 0),
        (56, 0),
        (56, 105),
        (105, 105),
        (105, 0),
        (153, 0),
        (153, 260),
        (105, 260),
        (105, 150),
        (8, 150)
      ], color);
      break;
    case '5':
      polygon([
        (8, 5),
        (153, 5),
        (153, 50),
        (55, 50),
        (55, 103),
        (124, 103),
        (153, 132),
        (153, 230),
        (124, 260),
        (8, 260),
        (8, 215),
        (101, 215),
        (107, 207),
        (107, 156),
        (99, 148),
        (8, 148)
      ], color);
      break;
    case '6':
      roundedRect(5, 0, 155, 260, 22, color);
      roundedRect(52, 45, 155, 102, 8, clear);
      roundedRect(52, 145, 108, 215, 8, clear);
      break;
    case '7':
      polygon([
        (5, 0),
        (155, 0),
        (155, 48),
        (98, 260),
        (48, 260),
        (105, 48),
        (5, 48)
      ], color);
      break;
    case '8':
      roundedRect(5, 0, 155, 260, 22, color);
      roundedRect(52, 43, 108, 105, 8, clear);
      roundedRect(52, 153, 108, 217, 8, clear);
      break;
    case '9':
      roundedRect(5, 0, 155, 260, 22, color);
      roundedRect(52, 45, 108, 112, 8, clear);
      roundedRect(5, 157, 108, 215, 8, clear);
      break;
  }
}

img.Image _legacyIcon(img.Image foreground) {
  final output = img.Image(width: 1024, height: 1024, numChannels: 4);
  for (var y = 0; y < 1024; y++) {
    final t = y / 1023;
    final r = (3 + 5 * t).round();
    final g = (67 - 20 * t).round();
    final b = (48 - 13 * t).round();
    for (var x = 0; x < 1024; x++) {
      output.setPixelRgba(x, y, r, g, b, 255);
    }
  }
  img.compositeImage(output, foreground);
  return output;
}

img.Image _resize(img.Image source, int size) => img.copyResize(
      source,
      width: size,
      height: size,
      interpolation: img.Interpolation.average,
    );

img.Image _monochrome(img.Image foreground) {
  final output = img.Image.from(foreground);
  for (final pixel in output) {
    final alpha = pixel.a.toInt();
    output.setPixelRgba(pixel.x, pixel.y, 255, 255, 255, alpha);
  }
  return output;
}

void _validateSafeArea(img.Image foreground, String number) {
  var minX = foreground.width;
  var minY = foreground.height;
  var maxX = 0;
  var maxY = 0;
  for (final pixel in foreground) {
    if (pixel.a > 12) {
      minX = math.min(minX, pixel.x);
      minY = math.min(minY, pixel.y);
      maxX = math.max(maxX, pixel.x);
      maxY = math.max(maxY, pixel.y);
    }
  }
  final margin = (foreground.width * .12).round();
  if (minX < margin ||
      minY < margin ||
      maxX >= foreground.width - margin ||
      maxY >= foreground.height - margin) {
    throw StateError('Jersey $number exceeds the adaptive-icon safe area.');
  }
}

String _adaptiveXml(String number) => '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/launcher_background" />
    <foreground android:drawable="@drawable/jersey_${number}_foreground" />
    <monochrome android:drawable="@drawable/jersey_${number}_monochrome" />
</adaptive-icon>
''';

const _defaultAlias = '''
        <activity-alias android:name=".MainActivityDefault"
            android:enabled="true" android:exported="true"
            android:icon="@mipmap/ic_launcher"
            android:roundIcon="@mipmap/ic_launcher_round"
            android:theme="@style/LaunchTheme"
            android:targetActivity=".MainActivity">
            <intent-filter><action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity-alias>''';

String _androidAlias(String number) => '''
        <activity-alias android:name=".MainActivityJersey$number"
            android:enabled="false" android:exported="true"
            android:icon="@mipmap/jersey_$number"
            android:roundIcon="@mipmap/jersey_$number"
            android:theme="@style/LaunchTheme"
            android:targetActivity=".MainActivity">
            <intent-filter><action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity-alias>''';

String _plistIcon(String number) => '''
\t\t<key>Jersey$number</key><dict>
\t\t\t<key>CFBundleIconFiles</key><array><string>Jersey$number</string></array>
\t\t\t<key>UIPrerenderedIcon</key><false/>
\t\t</dict>''';

void _updateXcodeAlternateNames() {
  final names = StringBuffer()
    ..writeln('ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES = (');
  for (var number = minimumJerseyNumber;
      number <= maximumJerseyNumber;
      number++) {
    names.writeln('\t\t\t\t\tJersey$number,');
  }
  names.write('\t\t\t\t);');
  final file = File(_xcodeProject);
  final source = file.readAsStringSync();
  final setting =
      RegExp(r'ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES = \([\s\S]*?\);');
  if (!setting.hasMatch(source)) {
    throw StateError('Missing alternate AppIcon build setting.');
  }
  file.writeAsStringSync(source.replaceAll(setting, names.toString()));
}

void _writePng(String path, img.Image image) {
  final file = File(path)..parent.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image, level: 9));
}

void _replaceGeneratedSection(
    File file, String start, String end, String generated) {
  final source = file.readAsStringSync();
  final startIndex = source.indexOf(start);
  final endIndex = source.indexOf(end);
  if (startIndex < 0 || endIndex < startIndex) {
    throw StateError('Missing generation markers in ${file.path}');
  }
  file.writeAsStringSync(source.substring(0, startIndex + start.length) +
      '\n' +
      generated +
      source.substring(endIndex));
}
