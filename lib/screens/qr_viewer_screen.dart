import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../theme/app_theme.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import '../widgets/custom_snackbar.dart';

class QRViewerScreen extends StatefulWidget {
  const QRViewerScreen({super.key});

  @override
  State<QRViewerScreen> createState() => _QRViewerScreenState();
}

class _QRViewerScreenState extends State<QRViewerScreen> with RouteAwareMixin {
  @override
  void initState() {
    super.initState();
    StatusBarManager.setStatusBarColor(Colors.black);
  }

  @override
  void onEnterScreen() {
    StatusBarManager.setStatusBarColorWithDelay(Colors.black);
  }

  @override
  void onReturnToScreen() {
    StatusBarManager.setStatusBarColorWithDelay(Colors.black);
  }

  @override
  void dispose() {
    StatusBarManager.setStatusBarColor(AppTheme.primaryColor);
    super.dispose();
  }

  Future<void> _shareQR() async {
    try {
      // Cargar la imagen como bytes
      final ByteData data = await rootBundle.load(
        'assets/images/QRPago_datos.jpg',
      );
      final Uint8List bytes = data.buffer.asUint8List();

      // Obtener directorio temporal
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/qr_pago.jpg';

      // Escribir archivo temporal
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes);

      // Compartir archivo
      await Share.shareXFiles([
        XFile(tempPath),
      ], text: 'QR para ofrendas - Himnarios App\n¡Gracias por tu apoyo!');
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(
          context,
          'Error al compartir: $e',
        );
      }
    }
  }

  Future<void> _downloadQR() async {
    try {
      // Cargar la imagen como bytes
      final ByteData data = await rootBundle.load(
        'assets/images/QRPago_datos.jpg',
      );
      final Uint8List bytes = data.buffer.asUint8List();

      // Para Android, usar el directorio de documentos de la app (más seguro)
      if (Platform.isAndroid) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String downloadPath = '${appDocDir.path}/QR_Himnarios_App.jpg';
        final File downloadFile = File(downloadPath);
        await downloadFile.writeAsBytes(bytes);

        if (mounted) {
          CustomSnackBar.showSuccess(
            context,
            'QR guardado en documentos de la app',
          );
        }
      } else {
        // Para iOS, usar el directorio de documentos
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String downloadPath = '${appDocDir.path}/QR_Himnarios_App.jpg';
        final File downloadFile = File(downloadPath);
        await downloadFile.writeAsBytes(bytes);

        if (mounted) {
          CustomSnackBar.showSuccess(
            context,
            'QR guardado en documentos de la app',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(
          context,
          'Error al descargar: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'QR para Ofrendas',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // QR grande
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/QRPago_datos.jpg',
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.83,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Texto informativo
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'Ofrenda de Amor',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gracias por tu apoyo para seguir desarrollando herramientas que glorifiquen a Dios',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _shareQR,
                  icon: const Icon(Icons.share),
                  label: const Text(
                    'Compartir',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _downloadQR,
                  icon: const Icon(Icons.download),
                  label: const Text(
                    'Descargar',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
