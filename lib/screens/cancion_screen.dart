import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../data/canciones_service.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
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
  late List<int> _favoritos;
  double _fontSize = 22.0;
  static const double _minFontSize = 12.0;
  static const double _maxFontSize = 40.0;
  static const double _fontSizeStep = 2.0;

  final colorIcon = Colors.yellow[50];
  final tamanioIcon = 19.0;
  String _imagenFondo = 'loading'; // Initialize with default value

  @override
  void initState() {
    super.initState();
    _favoritos = List.from(widget.favoritos);
    _cargarVersionesCancion();
    StatusBarManager.setStatusBarColor(
      _getColorForHimnario(widget.himnario.nombre),
    );
  }

  @override
  void didUpdateWidget(CancionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favoritos != widget.favoritos) {
      setState(() {
        _favoritos = List.from(widget.favoritos);
      });
    }
  }

  @override
  void onEnterScreen() {
    StatusBarManager.setStatusBarColorWithDelay(
      _getColorForHimnario(widget.himnario.nombre),
    );
  }

  @override
  void onReturnToScreen() {
    StatusBarManager.setStatusBarColorWithDelay(
      _getColorForHimnario(widget.himnario.nombre),
    );
  }

  void _toggleFavorito(int cancionId) async {
    setState(() {
      if (_favoritos.contains(cancionId)) {
        _favoritos.remove(cancionId);
      } else {
        _favoritos.add(cancionId);
      }
    });
    widget.onToggleFavorito(cancionId);
  }

  void _aumentarLetra() {
    setState(() {
      if (_fontSize < _maxFontSize) {
        _fontSize += _fontSizeStep;
      }
    });
  }

  void _disminuirLetra() {
    setState(() {
      if (_fontSize > _minFontSize) {
        _fontSize -= _fontSizeStep;
      }
    });
  }

  void _compartirCancion() {
    final cancion = cancionActual;
    final himnario = widget.himnario;

    final textoCompartir =
        '''
🎵 ${cancion.titulo}
📖 Himnario: ${himnario.nombre}
🔢 Número: ${cancion.numero}

${cancion.letra}

---
Compartido desde Himnarios App
''';

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

  Future<void> _cargarVersionesCancion() async {
    final cancionesService = CancionesService();
    final todasLasCanciones = await cancionesService.getCancionesPorHimnario(
      widget.cancion.himnario,
    );

    final versiones = todasLasCanciones
        .where((c) => c.numero == widget.cancion.numero)
        .toList();

    setState(() {
      _versionesCancion = versiones;
    });

    if (versiones.length > 1) {
      _tabController = TabController(length: versiones.length, vsync: this);
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

  Cancion get cancionActual {
    if (_versionesCancion != null) {
      if (_versionesCancion!.length > 1) {
        return _versionesCancion![_currentTabIndex];
      } else if (_versionesCancion!.length == 1) {
        return _versionesCancion![0];
      }
    }
    return widget.cancion;
  }

  bool get tieneMultiplesVersiones =>
      _versionesCancion != null && _versionesCancion!.length > 1;

  Widget _formatearLetra(String letra) {
    final lineas = letra.split('\n');
    final widgets = <Widget>[];

    for (final linea in lineas) {
      if (linea.startsWith('(') && linea.endsWith(')')) {
        final himnarioColor = _getColorForHimnario(widget.himnario.nombre);
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _imagenFondo == 'default'
                  ? himnarioColor.withValues(alpha: 0.15)
                  : himnarioColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: himnarioColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.music_note,
                  size: 12,
                  color: _imagenFondo == 'default'
                      ? himnarioColor
                      : Colors.white,
                ),
                const SizedBox(width: 2),
                Text(
                  linea,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _imagenFondo == 'default'
                        ? himnarioColor
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (linea.toUpperCase().startsWith('CORO')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              linea,
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              linea,
              style: TextStyle(
                fontSize: _fontSize,
                height: 1.2,
                color: AppTheme.textColor,
                fontWeight: _imagenFondo == 'default'
                    ? FontWeight.normal
                    : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    return Column(children: widgets);
  }

  Color _getColorForHimnario(String nombre) {
    // Usar colores dinámicos desde cache o fallback a estáticos
    return DynamicTheme.getColorForHimnarioSync(nombre);
  }

  LinearGradient _getGradientForHimnario(String nombre) {
    // Usar gradientes dinámicos desde cache o fallback a estáticos
    return DynamicTheme.getGradientForHimnarioSync(nombre);
  }

  // Obtener el fondo del himnario
  Widget _buildBackground() {
    //print('🔄 Solicitando fondo para: ${widget.himnario.nombre}');

    // Si ya tenemos un fondo cargado que no sea 'loading', mostrarlo
    if (_imagenFondo != 'loading') {
      return _buildBackgroundWidget(_imagenFondo);
    }

    // Si estamos en estado 'loading', cargar el fondo
    Future.microtask(() async {
      try {
        final fondo = await DynamicTheme.getImagenFondoForHimnario(
          widget.himnario.nombre,
        );
        if (mounted) {
          setState(() {
            _imagenFondo = fondo;
            //int('🎨 Fondo cargado: $fondo');
          });
        }
      } catch (e) {
        print('❌ Error al cargar fondo: $e');
        if (mounted) {
          setState(() {
            _imagenFondo = 'default';
          });
        }
      }
    });

    // Mostrar el gradiente mientras se carga el fondo
    return _buildBackgroundWidget('loading');
  }

  Widget _buildBackgroundWidget(String fondo) {
    // Si no hay fondo o es 'default', usar el gradiente por defecto
    if (fondo == 'default' || fondo == 'loading') {
      return Container(
        decoration: BoxDecoration(
          //gradient: _getGradientForHimnario(widget.himnario.nombre),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(239, 246, 255, 1),
              Color.fromRGBO(245, 243, 255, 1),
              Color.fromRGBO(250, 245, 255, 1),
            ],
          ),
        ),
      );
    }

    // Si hay una imagen de fondo, intentar cargarla
    try {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondos/$fondo'),
            fit: BoxFit.cover,
            /*colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.2),
              BlendMode.darken,
            ),*/
          ),
        ),
      );
    } catch (e) {
      print('❌ Error al cargar imagen: $e');
      // Si hay un error, usar el gradiente por defecto
      return Container(
        decoration: BoxDecoration(
          //gradient: _getGradientForHimnario(widget.himnario.nombre),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(239, 246, 255, 1),
              Color.fromRGBO(245, 243, 255, 1),
              Color.fromRGBO(250, 245, 255, 1),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen o gradiente
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                // 🔹 Encabezado rediseñado
                Container(
                  decoration: BoxDecoration(
                    gradient: _getGradientForHimnario(widget.himnario.nombre),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 5,
                      left: 8,
                      right: 8,
                    ),
                    child: Column(
                      children: [
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '${cancionActual.numero} - ${cancionActual.titulo}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      height: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                  Text(
                                    widget.himnario.nombre,
                                    style: TextStyle(
                                      color: Colors.yellow[200],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 48), // Para mantener centrado
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Botón para disminuir letra
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.19),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _disminuirLetra,
                                icon: const Icon(
                                  Icons.text_decrease_rounded,
                                  color: Colors.white,
                                  size: 17,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botón para aumentar letra
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.19),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _aumentarLetra,
                                icon: const Icon(
                                  Icons.text_increase_rounded,
                                  color: Colors.white,
                                  size: 17,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botón para compartir
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.19),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _compartirCancion,
                                icon: const Icon(
                                  Icons.share,
                                  color: Colors.white,
                                  size: 17,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botón de favoritos
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _favoritos.contains(cancionActual.id)
                                    ? Colors.red.withValues(alpha: 0.7)
                                    : Colors.white.withValues(alpha: 0.19),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () =>
                                    _toggleFavorito(cancionActual.id),
                                icon: Icon(
                                  _favoritos.contains(cancionActual.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 17,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Pestañas de versiones si hay más de una
                if (tieneMultiplesVersiones)
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 35),
                      labelColor: _getColorForHimnario(widget.himnario.nombre),
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorColor: _getColorForHimnario(
                        widget.himnario.nombre,
                      ),
                      tabs: _versionesCancion!.map((version) {
                        return Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.language, size: 16),
                              const SizedBox(width: 5),
                              Text(version.idioma.toUpperCase()),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Contenido de la canción
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      color: _imagenFondo == 'default'
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.2),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
