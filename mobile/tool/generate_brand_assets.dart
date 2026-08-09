import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  // Default-brand master: a cricket-first shield with a hero-sized diagonal
  // bat and ball. Jersey variants intentionally use their separate numbered
  // shield template and are not modified by this generator.
  final sourceFile = File('assets/branding/cricket_scorer_mark_chroma.png');
  final decoded = img.decodePng(sourceFile.readAsBytesSync());
  if (decoded == null) throw StateError('Unable to decode brand master.');
  if (decoded.width < 1024 || decoded.height < 1024) {
    throw StateError('Brand master must be at least 1024 x 1024.');
  }

  final masterMark = img.copyResize(
    _removeMagenta(decoded),
    width: 1024,
    height: 1024,
    interpolation: img.Interpolation.average,
  );
  _writePng('assets/branding/cricket_scorer_mark.png', masterMark);
  _writePng('assets/branding/cricket_scorer_mark_1024.png', masterMark);

  final masterIcon = _launcher(1024, masterMark, markScale: .82);
  _writePng('assets/branding/cricket_scorer_icon_1024.png', masterIcon);
  _writePng('assets/branding/launcher_icon_master.png', masterIcon);

  const androidSizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };
  const adaptiveSizes = {
    'mdpi': 108,
    'hdpi': 162,
    'xhdpi': 216,
    'xxhdpi': 324,
    'xxxhdpi': 432,
  };
  for (final entry in androidSizes.entries) {
    _writePng(
      'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
      _launcher(entry.value, masterMark, markScale: .82),
    );
    _writePng(
      'android/app/src/main/res/mipmap-${entry.key}/ic_launcher_round.png',
      _launcher(entry.value, masterMark, markScale: .72),
    );
  }
  for (final entry in adaptiveSizes.entries) {
    _writePng(
      'android/app/src/main/res/mipmap-${entry.key}/ic_launcher_foreground.png',
      _transparentLayer(entry.value, masterMark, markScale: .66),
    );
    _writePng(
      'android/app/src/main/res/mipmap-${entry.key}/ic_launcher_monochrome.png',
      _monochromeLayer(entry.value, masterMark, markScale: .66),
    );
  }
  _writePng(
    'android/app/src/main/res/drawable-nodpi/brand_splash_logo.png',
    _transparentLayer(1024, masterMark, markScale: .80),
  );

  const launchSizes = {
    'LaunchImage.png': 168,
    'LaunchImage@2x.png': 336,
    'LaunchImage@3x.png': 504,
  };
  for (final entry in launchSizes.entries) {
    _writePng(
      'ios/Runner/Assets.xcassets/LaunchImage.imageset/${entry.key}',
      _transparentLayer(entry.value, masterMark, markScale: .72),
    );
  }

  const iosSizes = {
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
  for (final entry in iosSizes.entries) {
    _writePng(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
      _launcher(entry.value, masterMark, markScale: .82),
    );
  }

  const macSizes = {
    'app_icon_16.png': 16,
    'app_icon_32.png': 32,
    'app_icon_64.png': 64,
    'app_icon_128.png': 128,
    'app_icon_256.png': 256,
    'app_icon_512.png': 512,
    'app_icon_1024.png': 1024,
  };
  for (final entry in macSizes.entries) {
    _writePng(
      'macos/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
      _launcher(entry.value, masterMark, markScale: .82),
    );
  }

  _writePng('web/favicon.png', _launcher(32, masterMark, markScale: .80));
  _writePng('web/icons/Icon-192.png', _launcher(192, masterMark));
  _writePng('web/icons/Icon-512.png', _launcher(512, masterMark));
  _writePng(
    'web/icons/Icon-maskable-192.png',
    _launcher(192, masterMark, markScale: .68),
  );
  _writePng(
    'web/icons/Icon-maskable-512.png',
    _launcher(512, masterMark, markScale: .68),
  );
}

img.Image _removeMagenta(img.Image source) {
  final output = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 4,
  );
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final pixel = source.getPixel(x, y);
      final r = pixel.r.toDouble();
      final g = pixel.g.toDouble();
      final b = pixel.b.toDouble();
      final distance = math.sqrt(
        math.pow(r - 255, 2) + math.pow(g, 2) + math.pow(b - 255, 2),
      );
      final alpha = distance <= 60
          ? 0
          : distance >= 140
              ? pixel.a.toInt()
              : (((distance - 60) / 80) * pixel.a).round().clamp(0, 255);
      final despill = alpha < 255;
      output.setPixelRgba(
        x,
        y,
        despill ? math.min(r, g * 1.35).round() : r.round(),
        g.round(),
        despill ? math.min(b, g * 1.35).round() : b.round(),
        alpha,
      );
    }
  }
  return output;
}

img.Image _launcher(
  int size,
  img.Image mark, {
  double markScale = .82,
}) {
  final output = img.Image(width: size, height: size, numChannels: 4);
  for (var y = 0; y < size; y++) {
    final t = y / math.max(1, size - 1);
    final r = (11 * (1 - t) + 20 * t).round();
    final g = (110 * (1 - t) + 90 * t).round();
    final b = (79 * (1 - t) + 50 * t).round();
    for (var x = 0; x < size; x++) {
      output.setPixelRgba(x, y, r, g, b, 255);
    }
  }
  _placeMark(output, mark, markScale);
  return output;
}

img.Image _transparentLayer(
  int size,
  img.Image mark, {
  required double markScale,
}) {
  final output = img.Image(width: size, height: size, numChannels: 4);
  _placeMark(output, mark, markScale);
  return output;
}

img.Image _monochromeLayer(
  int size,
  img.Image mark, {
  required double markScale,
}) {
  final layer = _transparentLayer(size, mark, markScale: markScale);
  for (final pixel in layer) {
    if (pixel.a > 0) {
      layer.setPixelRgba(pixel.x, pixel.y, 255, 255, 255, pixel.a.toInt());
    }
  }
  return layer;
}

void _placeMark(img.Image canvas, img.Image mark, double scale) {
  final target = (canvas.width * scale).round();
  final resized = img.copyResize(
    mark,
    width: target,
    height: target,
    interpolation: img.Interpolation.cubic,
  );
  final left = (canvas.width - target) ~/ 2;
  final top = (canvas.height - target) ~/ 2;
  img.compositeImage(canvas, resized, dstX: left, dstY: top);
}

void _writePng(String path, img.Image image) {
  final file = File(path)..parent.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image, level: 9));
}
