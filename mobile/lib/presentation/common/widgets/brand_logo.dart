import 'package:flutter/material.dart';

/// The shared TurfScore brand mark used across application surfaces.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 40});

  static const assetPath = 'assets/branding/cricket_scorer_mark.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'TurfScore logo',
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        excludeFromSemantics: true,
      ),
    );
  }
}
