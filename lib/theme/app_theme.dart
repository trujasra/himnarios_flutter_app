import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(
    255,
    79,
    70,
    229,
  ); // Indigo-600
  static const Color secondaryColor = Color.fromARGB(
    255,
    124,
    58,
    237,
  ); // Purple-600
  static const Color backgroundColor = Color.fromARGB(
    255,
    248,
    250,
    252,
  ); // Slate-50
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF1E293B); // Slate-800

  // Colores de himnarios
  static const Color emeraldColor = Color.fromARGB(
    255,
    16,
    185,
    129,
  ); // Emerald-500
  static const Color emeraldDarkColor = Color.fromARGB(255, 5, 150, 105);
  static const Color violetColor = Color.fromARGB(
    255,
    139,
    92,
    246,
  ); // Violet-500
  static const Color violetDarkColor = Color.fromARGB(
    255,
    124,
    58,
    237,
  ); // Violet-600
  static const Color amberColor = Color.fromARGB(
    255,
    245,
    158,
    11,
  ); // Amber-500
  static const Color amberDarkColor = Color.fromARGB(
    255,
    217,
    119,
    6,
  ); // Amber-600
  static const Color statusBarColor = Color.fromARGB(230, 79, 70, 229);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: primaryColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textColor),
        bodyMedium: TextStyle(fontSize: 14, color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // Gradientes para himnarios
  static LinearGradient getGradientForHimnario(String color) {
    switch (color) {
      case 'emerald':
        return const LinearGradient(
          colors: [emeraldColor, emeraldDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'violet':
        return const LinearGradient(
          colors: [violetColor, violetDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'amber':
        return const LinearGradient(
          colors: [amberColor, amberDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  // Colores para himnarios
  static Color getColorForHimnario(String color) {
    switch (color) {
      case 'emerald':
        return emeraldColor;
      case 'violet':
        return violetColor;
      case 'amber':
        return amberColor;
      default:
        return primaryColor;
    }
  }

  // Gradiente principal de la app
  static const LinearGradient mainGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
