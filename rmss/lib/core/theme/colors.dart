import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFFF7A00);

  // --- Dark Mode ---

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    colorScheme: const ColorScheme.dark(
      primary: primaryOrange,
      surface: Color(0xFF1E1E1E),
      surfaceContainer: Color(0xFf252525),
      onSurface: Colors.white,
      onSurfaceVariant: Colors.grey,
    ),
    useMaterial3: true,
  );

  // --- Light Mode ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: const Color(0xFFF9F8F6),
    colorScheme: const ColorScheme.light(
      primary: primaryOrange,
      surface: Color(0xFFF9F8F6),
      surfaceContainer: Colors.white,
      onSurface: Color(0xFF2C2A29),
      onSurfaceVariant: Color(0xFF7A7571),
    ),
  );
}
