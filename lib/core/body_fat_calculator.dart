import 'dart:math';

class BodyFatCalculator {
  /// U.S. Navy Method for Body Fat Percentage
  /// Height, Waist, Neck, Hip are in CM
  static double calculate({
    required double height,
    required double waist,
    required double neck,
    double? hip, // Required for females
    bool isMale = true,
  }) {
    try {
      if (isMale) {
        // 495 / (1.0324 - 0.19077 * log10(waist - neck) + 0.15456 * log10(height)) - 450
        return 495 / (1.0324 - 0.19077 * _log10(waist - neck) + 0.15456 * _log10(height)) - 450;
      } else {
        if (hip == null) return 0.0;
        // 495 / (1.29579 - 0.35004 * log10(waist + hip - neck) + 0.22100 * log10(height)) - 450
        return 495 / (1.29579 - 0.35004 * _log10(waist + hip - neck) + 0.22100 * _log10(height)) - 450;
      }
    } catch (e) {
      return 0.0;
    }
  }

  static double _log10(num n) => log(n) / ln10;
}
