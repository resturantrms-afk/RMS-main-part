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
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF8A471C),
      onPrimaryContainer: Color(0xFFFFDCC4),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      outline: Color(0xFFA08D80),
      outlineVariant: Color(0xFF7D685A),
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
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFDCC4),
      onPrimaryContainer: Color(0xFF452104),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      outline: Color(0xFF877366),
      outlineVariant: Color(0xFFD3C3B9),
      surface: Color(0xFFFAF8FF),
      onSurface: Color(0xFF2A1E17),
      onSurfaceVariant: Color(0xFF5C4A3E),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFFAF8FF),
      surfaceContainer: Color(0xFFFAF8FF),
      surfaceContainerHigh: Color(0xFFEFE3D9),
      surfaceContainerHighest: Color(0xFFE8D9CD),
    ),
  );
}
