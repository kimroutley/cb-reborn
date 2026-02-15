import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme_data.dart';

/// Service for image processing related to theme generation.
class ImageProcessingService {
  ImageProcessingService._();

  static Future<Color> sampleSeedFromGlobalBackground() async {
    try {
      final data = await rootBundle.load(CBTheme.globalBackgroundAsset);
      final bytes = data.buffer.asUint8List();

      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 72,
        targetHeight: 72,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (rgba == null) {
        return CBTheme.defaultSeedColor;
      }

      final pixels = rgba.buffer.asUint8List();
      int totalR = 0;
      int totalG = 0;
      int totalB = 0;
      int count = 0;

      for (int i = 0; i < pixels.length; i += 16) {
        final r = pixels[i];
        final g = pixels[i + 1];
        final b = pixels[i + 2];
        final a = pixels[i + 3];
        if (a < 24) continue;
        totalR += r;
        totalG += g;
        totalB += b;
        count++;
      }

      if (count == 0) {
        return CBTheme.defaultSeedColor;
      }

      final avg = Color.fromARGB(
        0xFF,
        (totalR / count).round().clamp(0, 255),
        (totalG / count).round().clamp(0, 255),
        (totalB / count).round().clamp(0, 255),
      );

      final hsl = HSLColor.fromColor(avg);
      return hsl
          .withSaturation((hsl.saturation + 0.24).clamp(0.35, 1.0))
          .withLightness(hsl.lightness.clamp(0.30, 0.66))
          .toColor();
    } catch (_) {
      return CBTheme.defaultSeedColor;
    }
  }
}
