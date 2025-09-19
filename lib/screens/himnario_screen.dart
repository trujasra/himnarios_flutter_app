import 'package:flutter/material.dart';
import '../data/canciones_service.dart';
import '../models/himnario.dart';
import '../models/cancion.dart';
import '../theme/app_theme.dart';
import '../widgets/cancion_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import 'cancion_screen.dart';
import 'himnario_tabs_screen.dart';

class HimnarioScreen extends StatefulWidget {
  final Himnario himnario;
  final List<int> favoritos;
  final Function(int) onToggleFavorito;

  const HimnarioScreen({
    super.key,
    required this.himnario,
    required this.favoritos,
    required this.onToggleFavorito,
  });

  @override
  State<HimnarioScreen> createState() => _HimnarioScreenState();
}

class _HimnarioScreenState extends State<HimnarioScreen> with RouteAwareMixin {
  String busqueda = '';
  List<String> chipsSeleccionados = [];
  List<Cancion> canciones = [];
  bool isLoading = true;
  // Estado local de favoritos que se sincroniza con el callback
  late List<int> _favoritos;

  final CancionesService _cancionesService = CancionesService();

  @override
  void initState() {
    super.initState();
    _favoritos = List.from(widget.favoritos); // Copia local del estado
    _cargarCanciones();
    // Configurar la barra de estado con el color del himnario
    StatusBarManager.setStatusBarColor(
      _getColorForHimnario(widget.himnario.nombre),
    );
  }

  @override
  void didUpdateWidget(HimnarioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar el estado local cuando cambian los favoritos externos
    if (oldWidget.favoritos != widget.favoritos) {
      setState(() {
        _favoritos = List.from(widget.favoritos);
      });
    }
  }

  // Método para manejar el toggle de favoritos con actualización inmediata
  void _toggleFavorito(int cancionId) async {
    setState(() {
      if (_favoritos.contains(cancionId)) {
        _favoritos.remove(cancionId);
      } else {
        _favoritos.add(cancionId);
      }
    });

    // Llamar al callback para actualizar el estado global
    widget.onToggleFavorito(cancionId);
  }

  @override
  void onEnterScreen() {
    // Configurar la barra de estado cuando entramos a esta pantalla
    StatusBarManager.setStatusBarColorWithDelay(
      _getColorForHimnario(widget.himnario.nombre),
    );
  }

  @override
  void onReturnToScreen() {
    // Configurar la barra de estado cuando regresamos a esta pantalla
    StatusBarManager.setStatusBarColorWithDelay(
      _getColorForHimnario(widget.himnario.nombre),
    );
    // Recargar datos para reflejar cambios de configuración
    _cargarCanciones();
  }

  // Método para obtener el color específico según el nombre del himnario
  Color _getColorForHimnario(String nombre) {
    // Usar colores dinámicos desde cache o fallback a estáticos
    return DynamicTheme.getColorForHimnarioSync(nombre);
  }

  // Método para obtener el gradiente específico según el nombre del himnario
  LinearGradient _getGradientForHimnario(String nombre) {
    // Usar gradientes dinámicos desde cache o fallback a estáticos
    return DynamicTheme.getGradientForHimnarioSync(nombre);
  }

  Future<void> _cargarCanciones() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Cancion> cancionesData;
      
      // Si hay búsqueda o filtros, usar búsqueda optimizada
      if (busqueda.isNotEmpty || chipsSeleccionados.isNotEmpty) {
        final idiomasSeleccionados = chipsSeleccionados.isNotEmpty
            ? chipsSeleccionados.map((chip) => chip.split(' (').first).toList()
            : null;
            
        cancionesData = await _cancionesService.buscarCancionesPorHimnario(
          widget.himnario.nombre,
          busqueda: busqueda.isNotEmpty ? busqueda : null,
          idiomas: idiomasSeleccionados,
          limit: 500, // Limitar resultados para mejor rendimiento
        );
      } else {
        // Si no hay filtros, cargar todas las canciones
        cancionesData = await _cancionesService.getCancionesPorHimnario(
          widget.himnario.nombre,
        );
      }
      
      setState(() {
        canciones = cancionesData;
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando canciones del himnario: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> get chips {
    final idiomas = canciones.map((c) => c.idioma).toSet();
    return idiomas.map((idioma) {
      final count = canciones.where((c) => c.idioma == idioma).length;
      return '$idioma ($count)';
    }).toList();
  }

  List<Cancion> get cancionesDelHimnario {
    // Las canciones ya vienen filtradas desde la base de datos
    return canciones;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC), // Slate-50
              Colors.white,
              Color(0xFFF1F5F9), // Slate-100
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header del himnario
              Container(
                decoration: BoxDecoration(
                  gradient: _getGradientForHimnario(widget.himnario.nombre),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: 1.0,
                  ),
                  child: Column(
                    children: [
                      // Barra superior con botones
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  widget.himnario.nombre,
                                  style: const TextStyle(
                                    fontFamily: 'Berkshire Swash',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  widget.himnario.descripcion,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HimnarioTabsScreen(
                                    himnario: widget.himnario,
                                    favoritos: _favoritos,
                                    onToggleFavorito: _toggleFavorito,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.list,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Buscador y filtros
                      SearchBarWidget(
                        busqueda: busqueda,
                        onBusquedaChanged: (value) {
                          setState(() => busqueda = value);
                          _cargarCanciones(); // Recargar con nueva búsqueda
                        },
                        chips: chips,
                        chipsSeleccionados: chipsSeleccionados,
                        onChipsSeleccionados: (chips) {
                          setState(() => chipsSeleccionados = chips);
                          _cargarCanciones(); // Recargar con nuevos filtros
                        },
                        himnarioColor: _getColorForHimnario(
                          widget.himnario.nombre,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Lista de canciones
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: _getColorForHimnario(widget.himnario.nombre),
                        ),
                      )
                    : cancionesDelHimnario.isEmpty
                    ? const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No se encontraron canciones',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(9.0),
                        itemCount: cancionesDelHimnario.length,
                        itemBuilder: (context, index) {
                          final cancion = cancionesDelHimnario[index];
                          return CancionCard(
                            cancion: cancion,
                            himnario: widget.himnario,
                            isFavorite: _favoritos.contains(cancion.id),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CancionScreen(
                                    cancion: cancion,
                                    himnario: widget.himnario,
                                    favoritos: _favoritos,
                                    onToggleFavorito: _toggleFavorito,
                                  ),
                                ),
                              );
                            },
                            onToggleFavorito: () => _toggleFavorito(cancion.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
