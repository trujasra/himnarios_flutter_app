import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(
    255,
    41,
    95,
    152,
  ); // Indigo-600
  static const Color secondaryColor = Color.fromARGB(
    255,
    25,
    70,
    117,
  ); // Purple-600
  static const Color backgroundColor = Color.fromARGB(
    255,
    248,
    250,
    252,
  ); // Slate-50
  static const Color cardColor = Colors.white;
  static const Color textColor = Color.fromARGB(255, 30, 41, 59); // Slate-800

  // Colores de himnarios
  static const Color bendicionColor = Color.fromARGB(255, 238, 107, 65);
  static const Color bendicionDarkColor = Color.fromARGB(
    255,
    202,
    87,
    49,
  ); // Pink-600
  static const Color corosColor = Color.fromARGB(
    255,
    136,
    125,
    247,
  ); // Blue-500
  static const Color corosDarkColor = Color.fromARGB(
    255,
    103,
    95,
    197,
  ); // Blue-600
  static const Color calaColor = Color.fromARGB(
    255,
    29,
    196,
    156,
  ); // 255, 12, 173, 120
  static const Color calaDarkColor = Color.fromARGB(
    255,
    53,
    162,
    159,
  ); // 1,141,97
  static const Color lluviasColor = Color.fromARGB(
    255,
    79,
    141,
    252,
  ); // Amber-500
  static const Color lluviasDarkColor = Color.fromARGB(
    255,
    54,
    106,
    196,
  ); // Amber-600
  static const Color poderColor = Color.fromARGB(255, 238, 184, 0);
  static const Color poderDarkColor = Color.fromARGB(255, 253, 141, 20);

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

  static const LinearGradient mainGradientArribaAbajo = LinearGradient(
    colors: [secondaryColor, primaryColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
