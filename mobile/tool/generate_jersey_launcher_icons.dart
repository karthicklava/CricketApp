import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const minimumJerseyNumber = 1;
const maximumJerseyNumber = 99;
const _androidManifest = 'android/app/src/main/AndroidManifest.xml';
const _iosPlist = 'ios/Runner/Info.plist';
const _xcodeProject = 'ios/Runner.xcodeproj/project.pbxproj';
const _foregroundChroma =
    'assets/branding/launcher_shield_foreground_chroma.png';

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
  final chroma = img.decodeImage(File(_foregroundChroma).readAsBytesSync());
  if (chroma == null) throw StateError('Unable to decode $_foregroundChroma');
  final foregroundMaster = _removeMagenta(chroma);
  _writePng('assets/branding/launcher_shield_foreground.png', foregroundMaster);
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
        img.copyResize(legacy, width: 192, height: 192));
    for (final size in _androidLegacySizes.entries) {
      _writePng(
          'android/app/src/main/res/mipmap-${size.key}/jersey_$display.png',
          img.copyResize(legacy, width: size.value, height: size.value));
    }
    for (final size in _androidAdaptiveSizes.entries) {
      _writePng(
          'android/app/src/main/res/drawable-${size.key}/jersey_${display}_foreground.png',
          img.copyResize(foreground, width: size.value, height: size.value));
      _writePng(
          'android/app/src/main/res/drawable-${size.key}/jersey_${display}_monochrome.png',
          img.copyResize(monochrome, width: size.value, height: size.value));
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
      _writePng('${iosSet.path}/${size.key}',
          img.copyResize(legacy, width: size.value, height: size.value));
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
    'nativeSourceSize': 1024,
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

img.Image _removeMagenta(img.Image source) {
  final output =
      img.Image(width: source.width, height: source.height, numChannels: 4);
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final pixel = source.getPixel(x, y);
      final r = pixel.r.toDouble();
      final g = pixel.g.toDouble();
      final b = pixel.b.toDouble();
      final distance = math
          .sqrt(math.pow(r - 255, 2) + math.pow(g, 2) + math.pow(b - 255, 2));
      final alpha = distance <= 55
          ? 0
          : distance >= 145
              ? pixel.a.toInt()
              : (((distance - 55) / 90) * pixel.a).round().clamp(0, 255);
      output.setPixelRgba(x, y, r.round(), g.round(), b.round(), alpha);
    }
  }
  return output;
}

img.Image _numberedForeground(img.Image shield, String display) {
  final output = img.Image(width: 1024, height: 1024, numChannels: 4);
  final safeShield = img.copyResize(shield, width: 760, height: 760);
  img.compositeImage(output, safeShield, dstX: 132, dstY: 132);

  final textLayer = img.Image(width: 240, height: 90, numChannels: 4);
  for (var dx = 0; dx <= 2; dx++) {
    for (var dy = 0; dy <= 2; dy++) {
      img.drawString(textLayer, display,
          font: img.arial48,
          x: dx,
          y: dy,
          color: img.ColorRgba8(255, 255, 255, 255));
    }
  }
  final trimmed = img.trim(textLayer, mode: img.TrimMode.transparent);
  final width = display.length == 1 ? 150 : 360;
  final scaled = img.copyResize(trimmed,
      width: width,
      height: (trimmed.height * width / trimmed.width).round(),
      interpolation: img.Interpolation.cubic);
  var x = (1024 - scaled.width) ~/ 2;
  if (display == '1') x += 5;
  final y = 360;
  final shadow = img.Image.from(scaled);
  for (final pixel in shadow) {
    if (pixel.a > 0) {
      shadow.setPixelRgba(pixel.x, pixel.y, 112, 75, 5, pixel.a.toInt());
    }
  }
  img.compositeImage(output, shadow, dstX: x + 7, dstY: y + 8);
  img.compositeImage(output, scaled, dstX: x, dstY: y);
  return output;
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
  return img.quantize(output, numberOfColors: 192);
}

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
  if (minX < margin || minY < margin ||
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
