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
  late List<int> _favoritos;
  double _fontSize = 22.0;
  static const double _minFontSize = 16.0;
  static const double _maxFontSize = 32.0;
  static const double _fontSizeStep = 2.0;

  final colorIcon = Colors.yellow[50];
  final tamanioIcon = 19.0;

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
              color: himnarioColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: himnarioColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.music_note, size: 11, color: himnarioColor),
                const SizedBox(width: 2),
                Text(
                  linea,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: himnarioColor,
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
    if (nombre.toLowerCase().contains('bendición del cielo')) {
      return AppTheme.bendicionColor;
    } else if (nombre.toLowerCase().contains('coros cristianos')) {
      return AppTheme.corosColor;
    } else if (nombre.toLowerCase().contains('cala')) {
      return AppTheme.calaColor;
    } else if (nombre.toLowerCase().contains('poder del')) {
      return AppTheme.poderColor;
    } else if (nombre.toLowerCase().contains('lluvias de')) {
      return AppTheme.lluviasColor;
    } else {
      return AppTheme.getColorForHimnario(widget.himnario.color);
    }
  }

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
    } else if (nombre.toLowerCase().contains('poder del')) {
      return const LinearGradient(
        colors: [AppTheme.poderColor, AppTheme.poderDarkColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (nombre.toLowerCase().contains('lluvias de')) {
      return const LinearGradient(
        colors: [AppTheme.lluviasColor, AppTheme.lluviasDarkColor],
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
              // 🔹 Encabezado rediseñado
              Container(
                decoration: BoxDecoration(
                  gradient: _getGradientForHimnario(widget.himnario.nombre),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
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
                                    height: 0.85,
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
                      const SizedBox(height: 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: _disminuirLetra,
                            icon: Icon(
                              Icons.text_decrease_rounded,
                              color: colorIcon,
                              size: tamanioIcon,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: _aumentarLetra,
                            icon: Icon(
                              Icons.text_increase_rounded,
                              color: colorIcon,
                              size: tamanioIcon,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: _compartirCancion,
                            icon: Icon(
                              Icons.share,
                              color: colorIcon,
                              size: tamanioIcon,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () => _toggleFavorito(cancionActual.id),
                            icon: Icon(
                              _favoritos.contains(cancionActual.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _favoritos.contains(cancionActual.id)
                                  ? Colors.white
                                  : colorIcon,
                              size: tamanioIcon,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (tieneMultiplesVersiones)
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 35,
                    ), // más ancho
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
                            Icon(Icons.language, size: 16),
                            const SizedBox(width: 5),
                            Text(version.idioma.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Card(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
