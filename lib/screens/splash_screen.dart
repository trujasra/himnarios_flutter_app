import 'package:flutter/material.dart';
import '../data/canciones_service.dart';
import '../data/database_helper.dart';
import '../models/usuario.dart';
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
    // Check if database is already populated
    final estaPoblada = await dbHelper.isBaseDatosPoblada();

    // Only show delay if database is already populated
    if (estaPoblada) {
      await Future.delayed(const Duration(seconds: 2));
    }

    //await Future.delayed(const Duration(seconds: 2)); // Pequeño delay visual

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

    // Verificar usuario registrado
    final usuario = await cancionesService.getPrimerUsuarioRegistrado();

    if (!mounted) return; // 👈 Evita usar context si el widget ya no existe

    if (usuario != null) {
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo y título de la app
              Column(
                children: [
                  Image.asset(
                    "assets/images/LogoHimnariosApp.png",
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Himnarios App",
                    style: TextStyle(
                      fontFamily: "Berkshire Swash",
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Mensaje de bienvenida solo si hay usuario registrado
              const SizedBox(height: 120),
              FutureBuilder<Usuario?>(
                future: cancionesService.getPrimerUsuarioRegistrado(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Column(
                      children: [
                        const Text(
                          'Bienvenid@',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.data!.nombre,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Indicador de carga
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
