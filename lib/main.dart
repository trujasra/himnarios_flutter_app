import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
//import 'data/canciones_service.dart';

//import 'data/data_bendicion_del_cielo.dart';
//import 'data/data_cala.dart';
//import 'data/data_poder_del_evangelio.dart';

// RouteObserver para detectar cambios de navegación
final RouteObserver<Route<dynamic>> routeObserver = RouteObserver<Route<dynamic>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
 // 👇 forzamos que Flutter no elimine estos datos en release
  //final _forceIncludeBendicion = DataBendicionDelCielo.canciones;
  //final _forceIncludeCala = DataCala.canciones;
  //final _forceIncludePoder = DataPoderDelEvangelio.canciones;
  //debugPrint("DEBUG: Canciones Poder del Evangelio = ${_forceIncludeBendicion .length}");
  //debugPrint("DEBUG: Canciones Poder del Evangelio = ${_forceIncludeCala .length}");
  //debugPrint("DEBUG: Canciones Poder del Evangelio = ${_forceIncludePoder .length}");

  // Inicializar la base de datos
  //final cancionesService = CancionesService();
  //await cancionesService.inicializarBaseDatos();

  // Repoblar canciones de Cala para incluir nuevas canciones
  //await cancionesService.repoblarCancionesBendicionDelCielo();
  //await cancionesService.repoblarCancionesPoderDelEvangelio();

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
      //home: const HomeScreen(),
      home: const SplashScreen(),
    );
  }
}
