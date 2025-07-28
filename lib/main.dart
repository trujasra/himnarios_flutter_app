import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'data/canciones_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar la base de datos
  final cancionesService = CancionesService();
  await cancionesService.inicializarBaseDatos();
  
  // Repoblar canciones de Cala para incluir nuevas canciones
  await cancionesService.repoblarCancionesCala();
  
  runApp(const HimnariosApp());
}

class HimnariosApp extends StatelessWidget {
  const HimnariosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Himnarios',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
