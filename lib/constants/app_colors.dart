import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xfff7d858);
  static final Color shade1 =
      HSLColor.fromColor(primaryColor).withLightness(0.8).toColor();
  static final Color shade2 =
      HSLColor.fromColor(primaryColor).withLightness(0.7).toColor();
  static final Color shade3 =
      HSLColor.fromColor(primaryColor).withLightness(0.6).toColor();
  static final Color shade4 =
      HSLColor.fromColor(primaryColor).withLightness(0.5).toColor();

  static const Color primaryLightColor = Color(0xFFFFE4B5);
  static const Color primaryDarkColor = Color(0xFFFF8C00);

  static const Color secondaryColor = Color(0xFF4A90E2);

  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF5F5F5);

  static const Color textColor = Color(0xFF333333);
  static const Color textLightColor = Color(0xFF666666);

  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF2ECC71);
  static const Color tileColor = Color(0xFFFAFAFA);

  static const Color dividerColor = Color(0xFFE0E0E0);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFA500), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
