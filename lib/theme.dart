import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Definindo as cores como constantes estáticas
  static const Color gold = Color(0xFFC5A059);
  static const Color royalBlue = Color(0xFF1D3676);
  static const Color background = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2C3E50);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: royalBlue,
      colorScheme: const ColorScheme.light(
        primary: royalBlue,
        secondary: gold,
        surface: background,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: royalBlue),
        titleTextStyle: GoogleFonts.montserrat(
          color: royalBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(
            fontSize: 24, fontWeight: FontWeight.bold, color: royalBlue),
        bodyLarge: GoogleFonts.raleway(
            fontSize: 16, color: textDark, height: 1.5),
        bodyMedium: GoogleFonts.raleway(
            fontSize: 14, color: textDark),
        labelLarge: GoogleFonts.montserrat(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}