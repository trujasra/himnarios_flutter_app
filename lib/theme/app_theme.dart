import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(255, 0, 18, 99); // Indigo-600
  static const Color secondaryColor = Color.fromARGB(255, 0, 27, 148); // Purple-600
  static const Color backgroundColor = Color.fromARGB(
    255,
    248,
    250,
    252,
  ); // Slate-50
  static const Color cardColor = Colors.white;
  static const Color textColor = Color.fromARGB(255, 30, 41, 59); // Slate-800

  // Colores de himnarios
  static const Color bendicionColor = Color.fromARGB(255, 0, 33, 182);
  static const Color bendicionDarkColor = Color.fromARGB(
    255,
    0,
    26,
    139,
  ); // Pink-600
  static const Color corosColor = Color.fromARGB(255, 143, 0, 36); // Blue-500
  static const Color corosDarkColor = Color.fromARGB(
    255,
    99,
    0,
    25,
  ); // Blue-600
  static const Color calaColor = Color.fromARGB(255, 12, 173, 120); // Green-500
  static const Color calaDarkColor = Color.fromARGB(
    255,
    1,
    141,
    97,
  ); // Green-600
  static const Color lluviasColor = Color.fromARGB(
    255,
    245,
    158,
    11,
  ); // Amber-500
  static const Color lluviasDarkColor = Color.fromARGB(
    255,
    217,
    119,
    6,
  ); // Amber-600
  static const Color poderColor = Color.fromARGB(255, 139, 92, 246);
  static const Color poderDarkColor = Color.fromARGB(255, 105, 32, 231);
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
        shadowColor: Colors.black.withValues(alpha: 0.1),
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
      case 'poder':
        return const LinearGradient(
          colors: [poderColor, poderDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'violet':
        return const LinearGradient(
          colors: [violetColor, violetDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'lluvias':
        return const LinearGradient(
          colors: [lluviasColor, lluviasDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'bendicion':
        return const LinearGradient(
          colors: [bendicionColor, bendicionDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'coros':
        return const LinearGradient(
          colors: [corosColor, corosDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'cala':
        return const LinearGradient(
          colors: [calaColor, calaDarkColor],
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
      case 'poder':
        return poderColor;
      case 'violet':
        return violetColor;
      case 'lluvias':
        return lluviasColor;
      case 'bendicion':
        return bendicionColor;
      case 'coros':
        return corosColor;
      case 'cala':
        return calaColor;
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
