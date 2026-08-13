import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Utility to convert hex string to Color
  static Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static ThemeData getTheme(Brightness brightness, String brandColorHex) {
    final seedColor = _colorFromHex(brandColorHex);
    final font = GoogleFonts.plusJakartaSans().fontFamily;

    // Optional: We can still enforce our deep hearth for dark mode backgrounds if we want,
    // or let Material 3 decide. Let's let Material 3 calculate it perfectly.
    
    return ThemeData(
      brightness: brightness,
      fontFamily: font,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }
}
