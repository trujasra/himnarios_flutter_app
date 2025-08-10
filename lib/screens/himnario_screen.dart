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
import 'indice_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
      AppTheme.getColorForHimnario(widget.himnario.color),
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
      AppTheme.getColorForHimnario(widget.himnario.color),
    );
  }

  @override
  void onReturnToScreen() {
    // Configurar la barra de estado cuando regresamos a esta pantalla
    StatusBarManager.setStatusBarColorWithDelay(
      AppTheme.getColorForHimnario(widget.himnario.color),
    );
  }

  Future<void> _cargarCanciones() async {
    setState(() {
      isLoading = true;
    });

    try {
      final cancionesData = await _cancionesService.getCancionesPorHimnario(
        widget.himnario.nombre,
      );
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
    return canciones.where((cancion) {
      if (chipsSeleccionados.isNotEmpty) {
        // El chip es 'Idioma (cantidad)', así que solo compara el idioma
        final idiomasSeleccionados = chipsSeleccionados
            .map((chip) => chip.split(' (').first)
            .toList();
        if (!idiomasSeleccionados.contains(cancion.idioma)) return false;
      }
      if (busqueda.isNotEmpty) {
        final busq = busqueda.toLowerCase();
        final coincideNumero = cancion.numero.toString().contains(busq);
        final coincideTexto =
            cancion.titulo.toLowerCase().contains(busq) ||
            (cancion.tituloSecundario?.toLowerCase().contains(busq) ?? false);
        if (!coincideNumero && !coincideTexto) {
          return false;
        }
      }
      return true;
    }).toList();
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
                  gradient: AppTheme.getGradientForHimnario(
                    widget.himnario.color,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
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
                                  builder: (context) => IndiceScreen(
                                    himnario: widget.himnario,
                                    favoritos: _favoritos,
                                    onToggleFavorito: _toggleFavorito,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.list, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Buscador y filtros
                      SearchBarWidget(
                        busqueda: busqueda,
                        onBusquedaChanged: (value) =>
                            setState(() => busqueda = value),
                        chips: chips,
                        chipsSeleccionados: chipsSeleccionados,
                        onChipsSeleccionados: (chips) =>
                            setState(() => chipsSeleccionados = chips),
                      ),
                    ],
                  ),
                ),
              ),
              // Lista de canciones
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
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
                        padding: const EdgeInsets.all(16.0),
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
