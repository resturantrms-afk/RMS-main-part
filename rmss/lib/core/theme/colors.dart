import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFE88328);
  static const Color deepHearth = Color(0xFF2A1E17);

  // --- Dark Mode ---

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    scaffoldBackgroundColor: deepHearth,
    colorScheme: const ColorScheme.dark(
      primary: primaryOrange,
      surface: deepHearth,
      surfaceContainer: Color(0xFF35261D),
      surfaceContainerHigh: Color(0xFF402E23),
      surfaceContainerHighest: Color(0xFF4D382A),
      onSurface: Color(0xFFF5EFEA),
      onSurfaceVariant: Color(0xFFBBA598),
    ),
    useMaterial3: true,
  );

  // --- Light Mode ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    scaffoldBackgroundColor: const Color(0xFFFAF6F3),
    colorScheme: const ColorScheme.light(
      primary: primaryOrange,
      surface: Color(0xFFFAF6F3),
      surfaceContainer: Colors.white,
      onSurface: Color(0xFF2C2A29),
      onSurfaceVariant: Color(0xFF8C7A6E),
    ),
  );
}
