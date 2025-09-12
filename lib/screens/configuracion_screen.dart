import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/canciones_service.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import '../widgets/custom_snackbar.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen>
    with RouteAwareMixin {
  List<Himnario> himnarios = [];
  Map<String, bool> himnariosVisibles = {};
  bool isLoading = true;

  final CancionesService _cancionesService = CancionesService();

  // Colores predefinidos disponibles
  final List<Map<String, dynamic>> coloresDisponibles = [
    {'nombre': 'Azul Clásico', 'color': '#295F98', 'colorDark': '#194675'},
    {'nombre': 'Naranja Vibrante', 'color': '#EE6B41', 'colorDark': '#CA5731'},
    {'nombre': 'Índigo Moderno', 'color': '#887DF7', 'colorDark': '#675FC5'},
    {'nombre': 'Verde Esmeralda', 'color': '#1DC49C', 'colorDark': '#35A29F'},
    {'nombre': 'Azul Cielo', 'color': '#4F8DFC', 'colorDark': '#366AC4'},
    {'nombre': 'Amarillo Dorado', 'color': '#EEB800', 'colorDark': '#FD8D14'},
    {'nombre': 'Púrpura Real', 'color': '#8B5CF6', 'colorDark': '#7C3AED'},
    {'nombre': 'Rosa Coral', 'color': '#F472B6', 'colorDark': '#EC4899'},
    {'nombre': 'Verde Lima', 'color': '#84CC16', 'colorDark': '#65A30D'},
    {'nombre': 'Rojo Carmesí', 'color': '#EF4444', 'colorDark': '#DC2626'},
  ];

  // Imágenes de fondo disponibles
  final List<Map<String, String>> imagenesDisponibles = [
    {'nombre': 'Por Defecto', 'valor': 'default'},
    {'nombre': 'Cielo Azul', 'valor': 'cielo_azul'},
    {'nombre': 'Montañas', 'valor': 'montanas'},
    {'nombre': 'Océano', 'valor': 'oceano'},
    {'nombre': 'Bosque', 'valor': 'bosque'},
    {'nombre': 'Atardecer', 'valor': 'atardecer'},
    {'nombre': 'Abstracto', 'valor': 'abstracto'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    StatusBarManager.setStatusBarColor(AppTheme.primaryColor);
  }

  @override
  void onEnterScreen() {
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.primaryColor);
  }

  @override
  void onReturnToScreen() {
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.primaryColor);
  }

  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);

    try {
      final himnariosData = await _cancionesService.getHimnariosCompletos();
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        himnarios = himnariosData;

        // Cargar configuración de visibilidad
        for (var himnario in himnarios) {
          himnariosVisibles[himnario.nombre] =
              prefs.getBool('visible_${himnario.nombre}') ?? true;
        }

        isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleVisibilidad(String nombreHimnario, bool visible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('visible_$nombreHimnario', visible);

    setState(() {
      himnariosVisibles[nombreHimnario] = visible;
    });

    CustomSnackBar.showInfo(
      context,
      visible
          ? '$nombreHimnario ahora es visible'
          : '$nombreHimnario ahora está oculto',
    );
  }

  Future<void> _actualizarConfiguracion({
    required int idHimnario,
    String? color,
    String? colorDark,
    String? imagenFondo,
  }) async {
    try {
      print('🔄 Iniciando actualización para himnario ID: $idHimnario');
      print('🎨 Color: $color, Color Dark: $colorDark');

      await _cancionesService.actualizarConfiguracionHimnario(
        idHimnario: idHimnario,
        color: color,
        colorDark: colorDark,
        imagenFondo: imagenFondo,
      );

      print('🧹 Limpiando cache...');
      // Limpiar cache y recargar datos para mostrar los cambios
      DynamicTheme.clearCache();

      print('📥 Recargando cache...');
      await DynamicTheme.loadCache();

      print('🔄 Recargando datos de himnarios...');
      await _cargarDatos();

      print('✅ Actualización completada exitosamente');

      CustomSnackBar.showSuccess(
        context,
        'Configuración actualizada correctamente',
      );
    } catch (e) {
      print('❌ Error actualizando configuración: $e');
      CustomSnackBar.showError(context, 'Error al actualizar la configuración');
    }
  }

  void _mostrarSelectorColor(Himnario himnario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Seleccionar color para ${himnario.nombre}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: coloresDisponibles.length,
              itemBuilder: (context, index) {
                final colorData = coloresDisponibles[index];
                final isSelected = himnario.colorHex == colorData['color'];

                return GestureDetector(
                  onTap: () {
                    _actualizarConfiguracion(
                      idHimnario: himnario.id,
                      color: colorData['color'],
                      colorDark: colorData['colorDark'],
                    );
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(
                            int.parse(
                                  colorData['color'].substring(1),
                                  radix: 16,
                                ) +
                                0xFF000000,
                          ),
                          Color(
                            int.parse(
                                  colorData['colorDark'].substring(1),
                                  radix: 16,
                                ) +
                                0xFF000000,
                          ),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        colorData['nombre'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarSelectorImagenFondo(Himnario himnario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Seleccionar fondo para ${himnario.nombre}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: imagenesDisponibles.length,
              itemBuilder: (context, index) {
                final imagenData = imagenesDisponibles[index];
                final isSelected = himnario.imagenFondo == imagenData['valor'];

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getColorForImage(imagenData['valor']!),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Icon(
                      _getIconForImage(imagenData['valor']!),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    imagenData['nombre']!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    _actualizarConfiguracion(
                      idHimnario: himnario.id,
                      imagenFondo: imagenData['valor'],
                    );
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Color _getColorForImage(String imagen) {
    switch (imagen) {
      case 'cielo_azul':
        return Colors.blue;
      case 'montanas':
        return Colors.brown;
      case 'oceano':
        return Colors.teal;
      case 'bosque':
        return Colors.green;
      case 'atardecer':
        return Colors.orange;
      case 'abstracto':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForImage(String imagen) {
    switch (imagen) {
      case 'cielo_azul':
        return Icons.cloud;
      case 'montanas':
        return Icons.landscape;
      case 'oceano':
        return Icons.waves;
      case 'bosque':
        return Icons.forest;
      case 'atardecer':
        return Icons.wb_sunny;
      case 'abstracto':
        return Icons.auto_awesome;
      default:
        return Icons.image;
    }
  }

  Widget _buildHimnarioItem(Himnario himnario) {
    final isVisible = himnariosVisibles[himnario.nombre] ?? true;
    final colorWidget = DynamicTheme.getColorForHimnarioSync(himnario.nombre);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorWidget.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: colorWidget,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      himnario.nombre,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isVisible ? AppTheme.textColor : Colors.grey,
                      ),
                    ),
                    Text(
                      '${himnario.canciones} canciones',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isVisible,
                onChanged: (value) =>
                    _toggleVisibilidad(himnario.nombre, value),
                activeColor: colorWidget,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _mostrarSelectorColor(himnario),
                icon: const Icon(Icons.palette, size: 16),
                label: const Text('Color'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorWidget,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _mostrarSelectorImagenFondo(himnario),
                icon: const Icon(Icons.image, size: 16),
                label: const Text('Fondo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFF6FF), Color(0xFFF5F3FF), Color(0xFFFAF5FF)],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Configuración de Himnarios',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                Text(
                                  'Personaliza la visibilidad y colores de cada himnario',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lista de himnarios
                    Text(
                      'Himnarios Disponibles',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...himnarios.map(
                      (himnario) => _buildHimnarioItem(himnario),
                    ),

                    const SizedBox(height: 24),

                    const SizedBox(height: 24),

                    // Información adicional
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Los cambios se aplicarán inmediatamente. Los himnarios ocultos no aparecerán en la pantalla principal.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
