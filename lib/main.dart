import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

// RouteObserver para detectar cambios de navegación
final RouteObserver<Route<dynamic>> routeObserver = RouteObserver<Route<dynamic>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Activar wakelock para que la pantalla no se duerma
  WakelockPlus.enable(); // ✅ Funciona igual en la versión 0.4.0

  runApp(const HimnariosApp());

  // Configurar barra de estado con el color principal por defecto
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppTheme.primaryColor, // Usar el color principal
      statusBarIconBrightness: Brightness.light, // Iconos claros para fondo oscuro
      statusBarBrightness: Brightness.dark, // Para iOS
    ),
  );
}

class HimnariosApp extends StatelessWidget {
  const HimnariosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Himnarios',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorObservers: [routeObserver], // Agregar el RouteObserver
      home: const SplashScreen(),
    );
  }
}
