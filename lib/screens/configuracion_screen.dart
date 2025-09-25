import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/canciones_service.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import '../widgets/custom_snackbar.dart';
import 'package:himnarios_flutter_app/data/database_helper.dart';

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
    {'nombre': 'Verde Oscuro', 'color': '#0a9e30', 'colorDark': '#066a33'},
    {'nombre': 'Verde Esmeralda', 'color': '#1DC49C', 'colorDark': '#35A29F'},
    {'nombre': 'Azul Cielo', 'color': '#4FB1FC', 'colorDark': '#366AC4'},
    {'nombre': 'Amarillo Dorado', 'color': '#EEB800', 'colorDark': '#FD8D14'},
    {'nombre': 'Púrpura Real', 'color': '#A462F0', 'colorDark': '#7C3AED'},
    {'nombre': 'Rosa Coral', 'color': '#F472B6', 'colorDark': '#e92f8b'},
    {'nombre': 'Verde Lima', 'color': '#84CC16', 'colorDark': '#65A30D'},
    {'nombre': 'Rojo Carmesí', 'color': '#fa4e39', 'colorDark': '#DC2626'},
    {'nombre': 'Café Chocolate', 'color': '#983820', 'colorDark': '#612415'},
    {'nombre': 'Vino Rojizo', 'color': '#9a0404', 'colorDark': '#6f0303'},
    {'nombre': 'Plomo Oscuro', 'color': '#7c7e7e', 'colorDark': '#565757'},
    {'nombre': 'Palo de Rosa', 'color': '#ee7777', 'colorDark': '#B95E82'},
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
      // Obtener todos los himnarios, incluyendo los inactivos
      final himnariosData = await DatabaseHelper.instance.getHimnarios();

      // Mapear los datos crudos a objetos Himnario
      final himnariosList = <Himnario>[];

      for (var h in himnariosData) {
        // Obtener el conteo de canciones para este himnario
        final count = await _getCantidadCancionesPorHimnario(
          h['id_tipo_himnario'],
        );

        himnariosList.add(
          Himnario(
            id: h['id_tipo_himnario'],
            nombre: h['nombre'],
            color: h['color'] ?? '#295F98',
            colorSecundario: h['color_dark'] ?? '#194675',
            colorTexto: '000000', // Color de texto por defecto
            canciones: count,
            descripcion: h['descripcion'] ?? '',
            idiomas: [], // Se actualizará más adelante
            estadoRegistro: (h['estado_registro'] == 1) ? 1 : 0,
          ),
        );
      }

      // Inicializar visibilidad basada en estado_registro
      final Map<String, bool> visibilidad = {};
      for (var himnario in himnariosList) {
        visibilidad[himnario.nombre] = himnario.estadoRegistro == 1;
      }

      // Actualizar SharedPreferences para mantener consistencia
      final prefs = await SharedPreferences.getInstance();
      for (var entry in visibilidad.entries) {
        await prefs.setBool('visible_${entry.key}', entry.value);
      }

      setState(() {
        himnarios = himnariosList;
        himnariosVisibles = visibilidad;
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => isLoading = false);
      // Mostrar error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los himnarios: $e')),
        );
      }
    }
  }

  // Método auxiliar para obtener la cantidad de canciones por himnario
  Future<int> _getCantidadCancionesPorHimnario(int idHimnario) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) as count 
        FROM Cancion 
        WHERE id_tipo_himnario = ? AND estado_registro = 1
      ''',
        [idHimnario],
      );

      return result.first['count'] as int? ?? 0;
    } catch (e) {
      print('Error obteniendo cantidad de canciones: $e');
      return 0;
    }
  }

  Future<void> _toggleVisibilidad(String nombreHimnario, bool visible) async {
    try {
      // Obtener la lista completa de himnarios
      final himnariosData = await DatabaseHelper.instance.getHimnarios();
      final himnarioData = himnariosData.firstWhere(
        (h) => h['nombre'] == nombreHimnario,
      );

      // Verificar si es para desactivar y hay solo un himnario activo
      if (!visible) {
        final himnariosActivos = himnariosData
            .where((h) => h['estado_registro'] == 1)
            .length;

        // Si solo hay un himnario activo y es el que se quiere desactivar, mostrar error
        if (himnariosActivos <= 1 && himnarioData['estado_registro'] == 1) {
          if (mounted) {
            CustomSnackBar.showError(
              context,
              'Debe haber al menos un himnario activo',
            );
            setState(() {
              himnariosVisibles[nombreHimnario] = true; // Mantener activo
            });
          }
          return;
        }
      }

      // Mostrar diálogo de confirmación con colores
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          /*title: Text(
            visible ? '¿Activar himnario?' : '¿Desactivar himnario?',
            style: TextStyle(
              color: visible ? Colors.green : Colors.orange[800],
              fontWeight: FontWeight.bold,
            ),
          ),*/
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visible
                    ? '¿Estás seguro de que deseas activar $nombreHimnario?'
                    : '¿Estás seguro de que deseas desactivar $nombreHimnario?',
                style: TextStyle(fontSize: 16),
              ),
              if (!visible) SizedBox(height: 8),
              if (!visible)
                Text(
                  'No se mostrará en la lista principal hasta que lo actives nuevamente.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[800],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'CANCELAR',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: visible ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: Text(
                visible ? 'ACTIVAR' : 'DESACTIVAR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 8,
        ),
      );

      if (confirmado != true) {
        if (mounted) {
          setState(() {
            himnariosVisibles[nombreHimnario] = !visible;
          });
        }
        return;
      }

      // Actualizar en la base de datos
      final himnarioDataActual = himnariosData.firstWhere(
        (h) => h['nombre'] == nombreHimnario,
      );
      await DatabaseHelper.instance.actualizarConfiguracionHimnario(
        idHimnario: himnarioDataActual['id_tipo_himnario'],
        activo: visible,
      );

      // Actualizar estado local
      if (mounted) {
        setState(() {
          himnariosVisibles[nombreHimnario] = visible;
          // Actualizar el estado en la lista local
          final index = himnarios.indexWhere((h) => h.nombre == nombreHimnario);
          if (index != -1) {
            final himnarioActual = himnarios[index];
            himnarios[index] = himnarioActual.copyWith(
              estadoRegistro: visible ? 1 : 0,
            );
          }
        });

        // Mostrar mensaje de éxito
        final mensaje = visible
            ? '✅ Himnario activado correctamente'
            : '⏸️ Himnario desactivado correctamente';
        CustomSnackBar.showSuccess(context, mensaje);
      }
    } catch (e) {
      // Revertir cambio en caso de error
      if (mounted) {
        setState(() {
          himnariosVisibles[nombreHimnario] = !visible;
        });
        print('Error al actualizar visibilidad: $e');
        CustomSnackBar.showError(
          context,
          '❌ Error al ${visible ? 'activar' : 'desactivar'} el himnario',
        );
      }
    }
  }

  Future<void> _actualizarConfiguracion({
    required int idHimnario,
    String? color,
    String? colorDark,
    String? imagenFondo,
  }) async {
    try {
      //print('🔄 Iniciando actualización para himnario ID: $idHimnario');
      //print('🎨 Color: $color, Color Dark: $colorDark');

      await _cancionesService.actualizarConfiguracionHimnario(
        idHimnario: idHimnario,
        color: color,
        colorDark: colorDark,
        imagenFondo: imagenFondo,
      );

      //print('🧹 Limpiando cache...');
      // Limpiar cache y recargar datos para mostrar los cambios
      DynamicTheme.clearCache();

      //print('📥 Recargando cache...');
      await DynamicTheme.loadCache();

      //print('🔄 Recargando datos de himnarios...');
      await _cargarDatos();

      //print('✅ Actualización completada exitosamente');

      CustomSnackBar.showSuccess(
        context,
        'Configuración actualizada correctamente',
      );
    } catch (e) {
      //print('❌ Error actualizando configuración: $e');
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
            height: 320,
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
                // Función para normalizar códigos de color
                String normalizeColor(String? color) {
                  if (color == null || color.isEmpty) return '';
                  return color.startsWith('#')
                      ? color.substring(1).toUpperCase()
                      : color.toUpperCase();
                }

                // Obtener el color actual del himnario (usar colorHex si está disponible, si no, usar color)
                final colorActualHimnario = himnario.colorHex ?? himnario.color;

                // Normalizar colores para comparación
                final colorHimnario = normalizeColor(colorActualHimnario);
                final colorActual = normalizeColor(colorData['color']);

                // Verificar si es el color seleccionado
                bool isSelected = colorHimnario == colorActual;

                // Si no coincide, verificar también con el color oscuro
                if (!isSelected && colorData['colorDark'] != null) {
                  final colorDarkActual = normalizeColor(
                    colorData['colorDark'],
                  );
                  isSelected = colorHimnario == colorDarkActual;
                }

                // Debug: Mostrar información de comparación
                debugPrint(
                  '[DEBUG] Comparación de colores para ${himnario.nombre}',
                );
                debugPrint(
                  'Color actual: $colorActualHimnario (normalizado: $colorHimnario)',
                );
                debugPrint(
                  'Color opción: ${colorData['color']} (normalizado: $colorActual)',
                );
                debugPrint('Color oscuro opción: ${colorData['colorDark']}');
                debugPrint('¿Seleccionado? $isSelected');

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
                          ? Border.all(
                              color: Colors.white,
                              width: 4, // Borde grueso para el seleccionado
                            )
                          : null, // Sin borde para los no seleccionados
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                spreadRadius: 3,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null, // Sin sombra para los no seleccionados
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
    final isActive = himnario.estadoRegistro == 1;
    final buttonColor = isActive ? colorWidget : Colors.grey;
    final buttonStyle = isActive
        ? ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            // Deshabilitar el efecto de elevación
            elevation: 0,
            shadowColor: Colors.transparent,
          );

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
                  color: buttonColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: buttonColor,
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
                        color: isActive
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                    if (!isActive) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Himnario inactivo',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Colors.orange.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
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
                onPressed: isActive
                    ? () => _mostrarSelectorColor(himnario)
                    : null, // Deshabilitar si no está activo
                icon: Icon(
                  Icons.palette,
                  size: 16,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
                label: Text(
                  'Color',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                style: buttonStyle,
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: isActive
                    ? () => _mostrarSelectorImagenFondo(himnario)
                    : null, // Deshabilitar si no está activo
                icon: Icon(
                  Icons.image,
                  size: 16,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
                label: Text(
                  'Fondo',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                style: buttonStyle.copyWith(
                  backgroundColor: MaterialStatePropertyAll<Color>(
                    isActive ? Colors.grey.shade600 : Colors.grey.shade300,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
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
                                  'Personaliza la visibilidad, colores y fondo de cada himnario',
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
