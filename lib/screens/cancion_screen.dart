import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../data/canciones_service.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

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
  // Estado local de favoritos que se sincroniza con el callback
  late List<int> _favoritos;
  // Estado para el tamaño de la letra
  double _fontSize = 22.0;
  static const double _minFontSize = 16.0;
  static const double _maxFontSize = 32.0;
  static const double _fontSizeStep = 2.0;

  @override
  void initState() {
    super.initState();
    _favoritos = List.from(widget.favoritos); // Copia local del estado
    _cargarVersionesCancion();
    // Configurar la barra de estado con el color del himnario
    StatusBarManager.setStatusBarColor(_getColorForHimnario(widget.himnario.nombre));
  }

  @override
  void didUpdateWidget(CancionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar el estado local cuando cambian los favoritos externos
    if (oldWidget.favoritos != widget.favoritos) {
      setState(() {
        _favoritos = List.from(widget.favoritos);
      });
    }
  }

  @override
  void onEnterScreen() {
    // Configurar la barra de estado cuando entramos a esta pantalla
    StatusBarManager.setStatusBarColorWithDelay(_getColorForHimnario(widget.himnario.nombre));
  }

  @override
  void onReturnToScreen() {
    // Configurar la barra de estado cuando regresamos a esta pantalla
    StatusBarManager.setStatusBarColorWithDelay(_getColorForHimnario(widget.himnario.nombre));
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

  // Método para aumentar el tamaño de la letra
  void _aumentarLetra() {
    setState(() {
      if (_fontSize < _maxFontSize) {
        _fontSize += _fontSizeStep;
      }
    });
  }

  // Método para disminuir el tamaño de la letra
  void _disminuirLetra() {
    setState(() {
      if (_fontSize > _minFontSize) {
        _fontSize -= _fontSizeStep;
      }
    });
  }

  // Método para compartir la canción
  void _compartirCancion() {
    final cancion = cancionActual;
    final himnario = widget.himnario;
    
    final textoCompartir = '''
🎵 ${cancion.titulo}
📖 Himnario: ${himnario.nombre}
🔢 Número: ${cancion.numero}

${cancion.letra}

---
Compartido desde Himnarios App
''';

    // Usar el plugin de compartir
    Share.share(
      textoCompartir,
      subject: 'Canción: ${cancion.titulo} - ${himnario.nombre}',
    );
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
        // Usar el color específico del himnario para las notas musicales
        final himnarioColor = _getColorForHimnario(widget.himnario.nombre);
        final noteColorLight = himnarioColor.withOpacity(0.15);
        final noteColorBorder = himnarioColor.withOpacity(0.4);

        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: noteColorLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: noteColorBorder,
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: himnarioColor.withOpacity(0.06),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.music_note,
                  size: 8,
                  color: himnarioColor,
                ),
                const SizedBox(width: 2),
                Text(
                  linea,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: himnarioColor,
                    letterSpacing: 0.1,
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
               style: TextStyle(
                 fontSize: _fontSize,
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

  // Método para obtener el color específico según el nombre del himnario
  Color _getColorForHimnario(String nombre) {
    if (nombre.toLowerCase().contains('bendición del cielo')) {
      return AppTheme.bendicionColor;
    } else if (nombre.toLowerCase().contains('coros cristianos')) {
      return AppTheme.corosColor;
    } else if (nombre.toLowerCase().contains('cala')) {
      return AppTheme.calaColor;
    } else {
      return AppTheme.getColorForHimnario(widget.himnario.color);
    }
  }

  // Método para obtener el gradiente específico según el nombre del himnario
  LinearGradient _getGradientForHimnario(String nombre) {
    if (nombre.toLowerCase().contains('bendición del cielo')) {
      return const LinearGradient(
        colors: [AppTheme.bendicionColor, AppTheme.bendicionDarkColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (nombre.toLowerCase().contains('coros cristianos')) {
      return const LinearGradient(
        colors: [AppTheme.corosColor, AppTheme.corosDarkColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (nombre.toLowerCase().contains('cala')) {
      return const LinearGradient(
        colors: [AppTheme.calaColor, AppTheme.calaDarkColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return AppTheme.getGradientForHimnario(widget.himnario.color);
    }
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
                   gradient: _getGradientForHimnario(widget.himnario.nombre),
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
                                             // Botones de control
                       Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           // Botón para disminuir letra
                           IconButton(
                             onPressed: _disminuirLetra,
                             icon: const Icon(
                               Icons.remove_circle_outline,
                               color: Colors.white,
                               size: 20,
                             ),
                             tooltip: 'Disminuir letra',
                           ),
                           // Botón para aumentar letra
                           IconButton(
                             onPressed: _aumentarLetra,
                             icon: const Icon(
                               Icons.add_circle_outline,
                               color: Colors.white,
                               size: 20,
                             ),
                             tooltip: 'Aumentar letra',
                           ),
                           // Botón para compartir
                           IconButton(
                             onPressed: _compartirCancion,
                             icon: const Icon(
                               Icons.share,
                               color: Colors.white,
                               size: 20,
                             ),
                             tooltip: 'Compartir canción',
                           ),
                           // Botón de favorito
                           IconButton(
                             onPressed: () =>
                                 _toggleFavorito(cancionActual.id),
                             icon: Icon(
                               _favoritos.contains(cancionActual.id)
                                   ? Icons.favorite
                                   : Icons.favorite_border,
                               color: Colors.white,
                             ),
                           ),
                         ],
                       ),
                    ],
                  ),
                ),
              ),

                             // Pestañas de idiomas (solo si hay múltiples versiones)
               if (tieneMultiplesVersiones) ...[
                 Container(
                   decoration: BoxDecoration(
                     color: Colors.white,
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withOpacity(0.05),
                         blurRadius: 8,
                         offset: const Offset(0, 2),
                       ),
                     ],
                   ),
                   child: TabBar(
                     controller: _tabController,
                     labelColor: _getColorForHimnario(widget.himnario.nombre),
                     unselectedLabelColor: Colors.grey.shade600,
                     indicatorColor: _getColorForHimnario(widget.himnario.nombre),
                     indicatorWeight: 3,
                     indicatorSize: TabBarIndicatorSize.tab,
                     labelStyle: const TextStyle(
                       fontSize: 13,
                       fontWeight: FontWeight.w600,
                       letterSpacing: 0.3,
                     ),
                     unselectedLabelStyle: const TextStyle(
                       fontSize: 12,
                       fontWeight: FontWeight.w500,
                       letterSpacing: 0.2,
                     ),
                     dividerColor: Colors.transparent,
                     tabs: _versionesCancion!.map((version) {
                       return Tab(
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(20),
                             color: _tabController.index == _versionesCancion!.indexOf(version)
                                 ? _getColorForHimnario(widget.himnario.nombre).withOpacity(0.1)
                                 : Colors.transparent,
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Icon(
                                 Icons.language,
                                 size: 14,
                                 color: _tabController.index == _versionesCancion!.indexOf(version)
                                     ? _getColorForHimnario(widget.himnario.nombre)
                                     : Colors.grey.shade600,
                               ),
                               const SizedBox(width: 6),
                               Text(
                                 version.idioma,
                                 style: TextStyle(
                                   fontSize: 12,
                                   fontWeight: _tabController.index == _versionesCancion!.indexOf(version)
                                       ? FontWeight.w600
                                       : FontWeight.w500,
                                   color: _tabController.index == _versionesCancion!.indexOf(version)
                                       ? _getColorForHimnario(widget.himnario.nombre)
                                       : Colors.grey.shade600,
                                 ),
                               ),
                             ],
                           ),
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
