import 'package:flutter/material.dart';
import '../data/canciones_service.dart';
import '../data/database_helper.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'registro_screen.dart';

// Importar datos para evitar tree-shaking en release
import '../data/data_bendicion_del_cielo.dart';
import '../data/data_cala.dart';
import '../data/data_poder_del_evangelio.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final cancionesService = CancionesService();
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2)); // Pequeño delay visual

    // 👇 Forzamos inclusión de himnarios en release
    final _forceIncludeBendicion = DataBendicionDelCielo.canciones;
    final _forceIncludeCala = DataCala.canciones;
    final _forceIncludePoder = DataPoderDelEvangelio.canciones;

    debugPrint("DEBUG Bendición = ${_forceIncludeBendicion.length}");
    debugPrint("DEBUG Cala = ${_forceIncludeCala.length}");
    debugPrint("DEBUG Poder = ${_forceIncludePoder.length}");

    // Inicializar base de datos
    await cancionesService.inicializarBaseDatos();
    
    // Inicializar colores por defecto si no existen
    await cancionesService.inicializarColoresPorDefecto();
    
    // Cargar cache de colores dinámicos
    await DynamicTheme.loadCache();

      // Repoblar canciones de Cala para incluir nuevas canciones
  //await cancionesService.repoblarCancionesBendicionDelCielo();
  //await cancionesService.repoblarCancionesPoderDelEvangelio();

    final db = await dbHelper.database;

    // Verificar usuario registrado
    final usuarios = await db.query(
      "Usuario",
      where: "estado_registro = ?",
      whereArgs: [1],
    );

    if (!mounted) return; // 👈 Evita usar context si el widget ya no existe

    if (usuarios.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegistroScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/LogoHimnariosApp.png",
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              "Himnarios App",
              style: TextStyle(
                fontFamily: "Berkshire Swash",
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
