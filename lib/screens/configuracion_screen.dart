import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/canciones_service.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> with RouteAwareMixin {
  List<Himnario> himnarios = [];
  Map<String, bool> himnariosVisibles = {};
  Map<String, String> coloresHimnarios = {};
  bool isLoading = true;

  final CancionesService _cancionesService = CancionesService();

  // Colores disponibles
  final Map<String, Color> coloresDisponibles = {
    'Azul': AppTheme.primaryColor,
    'Índigo': AppTheme.corosColor,
    'Violeta': AppTheme.calaColor,
    'Naranja': AppTheme.bendicionColor,
    'Verde': AppTheme.poderColor,
    'Ámbar': AppTheme.lluviasColor,
  };

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
          himnariosVisibles[himnario.nombre] = prefs.getBool('visible_${himnario.nombre}') ?? true;
          coloresHimnarios[himnario.nombre] = prefs.getString('color_${himnario.nombre}') ?? 'Azul';
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          visible 
            ? '$nombreHimnario ahora es visible'
            : '$nombreHimnario ahora está oculto',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _cambiarColor(String nombreHimnario, String nuevoColor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('color_$nombreHimnario', nuevoColor);
    
    setState(() {
      coloresHimnarios[nombreHimnario] = nuevoColor;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Color de $nombreHimnario cambiado a $nuevoColor'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarSelectorColor(String nombreHimnario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Seleccionar color para $nombreHimnario',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: coloresDisponibles.length,
              itemBuilder: (context, index) {
                final nombreColor = coloresDisponibles.keys.elementAt(index);
                final color = coloresDisponibles.values.elementAt(index);
                final isSelected = coloresHimnarios[nombreHimnario] == nombreColor;

                return GestureDetector(
                  onTap: () {
                    _cambiarColor(nombreHimnario, nombreColor);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected 
                        ? Border.all(color: Colors.black, width: 3)
                        : null,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          nombreColor,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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

  Widget _buildHimnarioItem(Himnario himnario) {
    final isVisible = himnariosVisibles[himnario.nombre] ?? true;
    final colorSeleccionado = coloresHimnarios[himnario.nombre] ?? 'Azul';
    final colorWidget = coloresDisponibles[colorSeleccionado] ?? AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  onChanged: (value) => _toggleVisibilidad(himnario.nombre, value),
                  activeColor: colorWidget,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.palette,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Color: $colorSeleccionado',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _mostrarSelectorColor(himnario.nombre),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorWidget,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Cambiar',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
          decoration: const BoxDecoration(
            gradient: AppTheme.mainGradient,
          ),
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
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
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
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
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
                    
                    ...himnarios.map((himnario) => _buildHimnarioItem(himnario)),
                    
                    const SizedBox(height: 24),
                    
                    // Información adicional
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                        ),
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
