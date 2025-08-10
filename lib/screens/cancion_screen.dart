import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../data/canciones_service.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import 'package:google_fonts/google_fonts.dart';

class CancionScreen extends StatefulWidget {
  final Cancion cancion;
  final Himnario himnario;
  final List<int> favoritos;
  final Function(int) onToggleFavorito;

  const CancionScreen({
    super.key,
    required this.cancion,
    required this.himnario,
    required this.favoritos,
    required this.onToggleFavorito,
  });

  @override
  State<CancionScreen> createState() => _CancionScreenState();
}

class _CancionScreenState extends State<CancionScreen>
    with SingleTickerProviderStateMixin, RouteAwareMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  List<Cancion>? _versionesCancion;

  @override
  void initState() {
    super.initState();
    _cargarVersionesCancion();
    // Configurar la barra de estado con el color del himnario
    StatusBarManager.setStatusBarColor(AppTheme.getColorForHimnario(widget.himnario.color));
  }

  @override
  void onEnterScreen() {
    // Configurar la barra de estado cuando entramos a esta pantalla
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.getColorForHimnario(widget.himnario.color));
  }

  @override
  void onReturnToScreen() {
    // Configurar la barra de estado cuando regresamos a esta pantalla
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.getColorForHimnario(widget.himnario.color));
  }

  @override
  void dispose() {
    if (_versionesCancion != null && _versionesCancion!.length > 1) {
      _tabController.dispose();
    }
    super.dispose();
  }

  // Cargar todas las versiones de la canción actual
  Future<void> _cargarVersionesCancion() async {
    final cancionesService = CancionesService();
    final todasLasCanciones = await cancionesService.getCancionesPorHimnario(
      widget.cancion.himnario,
    );

    print(
      'DEBUG: Todas las canciones del himnario: ${todasLasCanciones.length}',
    );
    for (var c in todasLasCanciones) {
      print('  - Canción ${c.numero}: ${c.titulo} (${c.idioma})');
    }

    // Buscar todas las versiones de la canción actual (mismo número)
    final versiones = todasLasCanciones
        .where((c) => c.numero == widget.cancion.numero)
        .toList();

    print('DEBUG: Buscando canción número ${widget.cancion.numero}');
    print('DEBUG: Versiones encontradas: ${versiones.length}');
    for (var v in versiones) {
      print(
        '  - Versión: ${v.titulo} (${v.idioma}) - Letra: ${v.letra.isNotEmpty ? "SÍ" : "NO"}',
      );
    }

    setState(() {
      _versionesCancion = versiones;
    });

    // Inicializar TabController si hay múltiples versiones
    if (versiones.length > 1) {
      _tabController = TabController(length: versiones.length, vsync: this);

      // Encontrar el índice de la versión actual
      final indexActual = versiones.indexWhere(
        (c) => c.idioma == widget.cancion.idioma,
      );
      if (indexActual != -1) {
        _tabController.index = indexActual;
        _currentTabIndex = indexActual;
      }

      _tabController.addListener(() {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      });
    }
  }

  // Obtener la canción actual (versión seleccionada o la original)
  Cancion get cancionActual {
    print(
      'DEBUG: cancionActual - _versionesCancion: ${_versionesCancion?.length ?? "null"}',
    );

    if (_versionesCancion != null) {
      if (_versionesCancion!.length > 1) {
        print(
          'DEBUG: Usando versión múltiple: ${_versionesCancion![_currentTabIndex].titulo}',
        );
        return _versionesCancion![_currentTabIndex];
      } else if (_versionesCancion!.length == 1) {
        print(
          'DEBUG: Usando versión única: ${_versionesCancion![0].titulo} - Letra: ${_versionesCancion![0].letra.isNotEmpty ? "SÍ" : "NO"}',
        );
        return _versionesCancion![0];
      }
    }
    print(
      'DEBUG: Usando widget.cancion: ${widget.cancion.titulo} - Letra: ${widget.cancion.letra.isNotEmpty ? "SÍ" : "NO"}',
    );
    return widget.cancion;
  }

  // Verificar si hay múltiples versiones
  bool get tieneMultiplesVersiones =>
      _versionesCancion != null && _versionesCancion!.length > 1;

  // Formatear la letra con estilos especiales
  Widget _formatearLetra(String letra) {
    final lineas = letra.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lineas.length; i++) {
      final linea = lineas[i].trim();

      // Espacio extra si es línea vacía (separación de estrofas)
      // if (linea.isEmpty) {
      //   widgets.add(const SizedBox(height: 30));
      //   continue;
      // }

      if (linea.startsWith('(') && linea.endsWith(')')) {
        final baseColor = const Color.fromARGB(255, 178, 38, 221); // azul petróleo

        widgets.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.1), // fondo muy suave azul
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: baseColor.withValues(alpha:0.1), width: 2),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withValues(alpha:0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.music_note, size: 12, color: baseColor),
                const SizedBox(width: 1),
                Text(
                  linea,
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: baseColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Detectar si es CORO
      else if (linea.toUpperCase() == 'CORO' ||
          linea.toUpperCase() == 'CORO:' ||
          linea.toUpperCase() == 'CORO :') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              linea,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
                fontStyle: FontStyle.italic,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      // Detectar si es autor (líneas que contienen nombres comunes de autores)
      // else if (_esAutor(linea)) {
      //   widgets.add(
      //     Padding(
      //       padding: const EdgeInsets.only(top: 20, bottom: 8),
      //       child: Text(
      //         linea,
      //         style: TextStyle(
      //           fontSize: 14,
      //           color: Colors.orange[700],
      //           fontStyle: FontStyle.italic,
      //         ),
      //         textAlign: TextAlign.center,
      //       ),
      //     ),
      //   );
      // }
      // Texto normal de la letra
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              linea,
              style: const TextStyle(
                fontSize: 22,
                height: 1.2,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    return Column(children: widgets);
  }

  // Detectar si una línea es autor
  bool _esAutor(String linea) {
    final autores = [
      'Mario Zeballos',
      'Guillermo Zeballos',
      'Zeballos',
      'Ch.',
      'Ch',
    ];

    return autores.any((autor) => linea.contains(autor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFF6FF), Color(0xFFF5F3FF), Color(0xFFFAF5FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
                             // Header con botón de regreso y favorito
               Container(
                 decoration: BoxDecoration(
                   gradient: AppTheme.getGradientForHimnario(widget.himnario.color),
                 ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '#${cancionActual.numero} - ${cancionActual.titulo}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                            Text(
                              widget.himnario.nombre,
                              style: TextStyle(
                                color: Colors.yellow[100],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            widget.onToggleFavorito(cancionActual.id),
                        icon: Icon(
                          widget.favoritos.contains(cancionActual.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pestañas de idiomas (solo si hay múltiples versiones)
              if (tieneMultiplesVersiones) ...[
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: _versionesCancion!.map((version) {
                      return Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.language, size: 16),
                            const SizedBox(width: 4),
                            Text(version.idioma),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              // Contenido de la canción
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Letra de la canción con zoom - Fondo blanco que ocupa todo el ancho
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 20.0,
                            ),
                            child: _formatearLetra(cancionActual.letra),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
