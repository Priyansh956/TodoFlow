// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/task_model.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFFEDECFF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color accent = Color(0xFF43C59E);

  static const Color todoColor = Color(0xFF90A4AE);
  static const Color inProgressColor = Color(0xFF7E57C2);
  static const Color doneColor = Color(0xFF43C59E);
  static const Color overdueColor = Color(0xFFEF5350);

  static const Color bgLight = Color(0xFFF8F7FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFEEEDF6);

  static const Color bgDark = Color(0xFF13131F);
  static const Color surfaceDark = Color(0xFF1E1E2E);
  static const Color cardDark = Color(0xFF252538);
  static const Color borderDark = Color(0xFF2E2E42);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surfaceLight,
      primary: primary,
    ),
    scaffoldBackgroundColor: bgLight,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: bgLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderLight),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F4FF),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: overdueColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: overdueColor, width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      hintStyle: const TextStyle(color: Color(0xFFB0B0C0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle:
        GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: CircleBorder(),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1A1A2E),
      contentTextStyle: GoogleFonts.inter(color: Colors.white),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme:
    const DividerThemeData(color: borderLight, thickness: 1),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: surfaceDark,
      primary: primary,
    ),
    scaffoldBackgroundColor: bgDark,
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderDark),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: overdueColor),
      ),
      labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle:
        GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF9D97FF),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: CircleBorder(),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: cardDark,
      contentTextStyle: GoogleFonts.inter(color: Colors.white),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme:
    const DividerThemeData(color: borderDark, thickness: 1),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
  );

  static Color statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return todoColor;
      case TaskStatus.inProgress:
        return inProgressColor;
      case TaskStatus.done:
        return doneColor;
    }
  }

  static Color statusBgColor(TaskStatus status) {
    return statusColor(status).withOpacity(0.12);
  }
}