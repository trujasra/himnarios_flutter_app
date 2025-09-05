import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 necesario para inputFormatters
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_theme.dart';
import '../data/database_helper.dart';
import 'home_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final FocusNode _nombreFocus = FocusNode(); // <- Foco agregado
  final dbHelper = DatabaseHelper.instance;
  bool _loading = false;
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    _cargarVersion();

    // Pedir el foco automáticamente al primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nombreFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nombreFocus.dispose(); // <- liberar focus
    super.dispose();
  }

  Future<void> _cargarVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = "v${info.version}";
    });
  }

  Future<void> _registrarUsuario() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty || nombre.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ El nombre debe tener al menos 3 caracteres"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final db = await dbHelper.database;
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    await db.insert("Usuario", {
      "nombre": nombre,
      "estado_registro": 1,
      "fecha_registro": now,
      "usuario_registro": "ramiro.trujillo",
      "fecha_modificacion": null,
      "usuario_modificacion": null,
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradientArribaAbajo,
        ),
        child: Center(
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // LOGO
                      Image.asset(
                        "assets/images/LogoHimnariosApp.png",
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Himnarios App",
                        style: TextStyle(
                          fontFamily: "Berkshire Swash",
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 90),

                      // Mensaje bendición
                      const Text(
                        "Dios te bendiga",
                        style: TextStyle(
                          fontFamily: 'Berkshire Swash',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "La aplicación pertenecerá a:",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // CARD con campo
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _nombreController,
                              textCapitalization:
                                  TextCapitalization.characters, // 👈 Uppercase
                              inputFormatters: [
                                UpperCaseTextFormatter(), // 👈 Formatter
                                LengthLimitingTextInputFormatter(
                                  35,
                                ), // 👈 Máx 35 caracteres
                              ],
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: AppTheme.primaryColor,
                                ),
                                labelText: "Nombre completo",
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${_nombreController.text.length}/35",
                              style: TextStyle(
                                fontSize: 12,
                                color: _nombreController.text.length >= 35
                                    ? Colors.redAccent
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Botón Registrar
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor:
                                      _nombreController.text.trim().length >= 3
                                      ? AppTheme.primaryColor
                                      : Colors.grey, // 👈 deshabilitado
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 6,
                                  shadowColor: AppTheme.secondaryColor
                                      .withValues(alpha: 0.4),
                                ),
                                onPressed:
                                    _nombreController.text.trim().length >= 3
                                    ? _registrarUsuario
                                    : null, // 👈 bloqueado si < 3
                                child: const Text(
                                  "Registrar",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Versión app
                      Text(
                        _appVersion.isNotEmpty ? _appVersion : "version",
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// 👇 Formatter para forzar mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
