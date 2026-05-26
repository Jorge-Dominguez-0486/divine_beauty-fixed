import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor =
      Color(0xFFFFB6C1); // rosa claro (AppBar, botones)
  static const Color accentColor =
      Color(0xFFE75480); // rosa oscuro (íconos activos, énfasis)
  static const Color secondaryColor = Color(0xFFF8BBD0);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFFF0F5);
  static const Color textPrimaryColor = Color(0xFF4A4A4A);
  static const Color textSecondaryColor = Color(0xFF8A8A8A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: accentColor, // rosa oscuro para ítems activos
        secondary: secondaryColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
            color: textPrimaryColor, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.playfairDisplay(
            color: textPrimaryColor, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.playfairDisplay(
            color: textPrimaryColor, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.playfairDisplay(
            color: textPrimaryColor, fontWeight: FontWeight.w500),
        titleLarge: GoogleFonts.montserrat(
            color: textPrimaryColor, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.montserrat(
            color: textPrimaryColor, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.montserrat(color: textPrimaryColor),
        bodyMedium: GoogleFonts.montserrat(color: textPrimaryColor),
        bodySmall: GoogleFonts.montserrat(color: textSecondaryColor),
        labelLarge: GoogleFonts.montserrat(
            color: textPrimaryColor, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: accentColor, // rosa oscuro visible
        unselectedItemColor: Color(0xFFBBBBBB),
        selectedLabelStyle:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accentColor : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accentColor.withOpacity(0.4)
              : Colors.grey.shade300,
        ),
      ),
    );
  }
}
