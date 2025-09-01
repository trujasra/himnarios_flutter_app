import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';
import 'home_screen.dart';
import 'registro_screen.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2)); // 👀 pequeño delay visual

    final db = await dbHelper.database;

    // Verificar si hay usuario registrado con estado_registro = 1
    final usuarios = await db.query(
      "Usuario",
      where: "estado_registro = ?",
      whereArgs: [1],
    );

    if (usuarios.isNotEmpty) {
      // Usuario ya registrado ✅
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // No existe usuario → registrar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegistroScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO de tu app
            Image.asset(
              "assets/images/logo_himnario.png", // 👀 asegúrate de tenerlo en assets
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
