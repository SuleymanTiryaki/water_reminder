import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2196F3); // Water Blue
  static const Color secondaryColor = Color(0xFF64B5F6);
  static const Color backgroundColor = Color(0xFFE3F2FD); // Light Blue Background

  static ThemeData light = ThemeData(
    primaryColor: primaryColor,
    indicatorColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    unselectedWidgetColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      error: Colors.red,
    ),
    fontFamily: "Comfortaa",
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 60.0,
      ),
      headlineMedium: TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 24.0,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF1976D2),
        fontWeight: FontWeight.w400,
        fontSize: 20.0,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF1565C0),
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
      ),
      bodySmall: TextStyle(
        color: Color(0xFF42A5F5),
        fontWeight: FontWeight.w400,
        fontSize: 14.0,
      ),
    ),
    iconTheme: IconThemeData(
      color: primaryColor,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primaryColor,
      selectionHandleColor: primaryColor,
      selectionColor: primaryColor.withOpacity(0.3),
    ),
  );
}
