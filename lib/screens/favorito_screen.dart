import 'package:flutter/material.dart';
import '../data/canciones_service.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../widgets/cancion_card.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import 'cancion_screen.dart';

class FavoritoScreen extends StatefulWidget {
  final bool mostrarBotonCerrar;
  final String? himnarioFiltro;

  const FavoritoScreen({
    super.key,
    this.mostrarBotonCerrar = false,
    this.himnarioFiltro,
  });

  @override
  State<FavoritoScreen> createState() => _FavoritoScreenState();
}

class _FavoritoScreenState extends State<FavoritoScreen> with RouteAwareMixin {
  List<int> favoritos = [];
  List<Cancion> canciones = [];
  List<Himnario> himnarios = [];
  bool isLoading = true;
  Map<String, bool> _expandedSections = {};

  final CancionesService _cancionesService = CancionesService();

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
    _cargarDatos(); // Recargar datos cuando se regresa a la pantalla
  }

  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);

    try {
      final cancionesData = await _cancionesService.getCanciones();
      final himnariosData = await _cancionesService.getHimnariosCompletos();
      final favoritosData = await _cancionesService.getFavoritos();

      setState(() {
        canciones = cancionesData;
        himnarios = himnariosData;
        favoritos = favoritosData;
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleFavorito(int cancionId) async {
    try {
      if (favoritos.contains(cancionId)) {
        await _cancionesService.quitarFavorito(cancionId);
        setState(() => favoritos.remove(cancionId));
      } else {
        await _cancionesService.agregarFavorito(cancionId);
        setState(() => favoritos.add(cancionId));
      }
    } catch (e) {
      print('Error cambiando favorito: $e');
    }
  }

  void _toggleFavorito(int cancionId) async {
    await toggleFavorito(cancionId);
  }

  Widget tituloFavoritos() {
    final titulo = widget.himnarioFiltro != null
        ? 'Favoritos - ${widget.himnarioFiltro}'
        : 'Mis Favoritos';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade900.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 26,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              height: 0.98,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsibleSection(
    String nombreHimnario,
    List<Cancion> cancionesDelHimnario,
  ) {
    final isExpanded = _expandedSections[nombreHimnario] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header colapsable
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[nombreHimnario] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DynamicTheme.getColorForHimnarioSync(
                        nombreHimnario,
                      ).withValues(alpha: 0.1),
                      /*gradient: LinearGradient(
                        colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 25, 189, 210).withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                        ),
                      ],*/
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: DynamicTheme.getColorForHimnarioSync(
                        nombreHimnario,
                      ),
                      size: 20,
                      /*shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(1, 1),
                        ),
                      ],*/
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nombreHimnario,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${cancionesDelHimnario.length}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          // Contenido colapsable
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: cancionesDelHimnario.map((cancion) {
                  final himnarioCancion = himnarios.firstWhere(
                    (h) => h.nombre == cancion.himnario,
                  );
                  return CancionCard(
                    cancion: cancion,
                    himnario: himnarioCancion,
                    isFavorite: true,
                    mostrarHimnario: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CancionScreen(
                            cancion: cancion,
                            himnario: himnarioCancion,
                            favoritos: favoritos,
                            onToggleFavorito: _toggleFavorito,
                          ),
                        ),
                      );
                    },
                    onToggleFavorito: () => _toggleFavorito(cancion.id),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar canciones favoritas
    var cancionesFavoritas = canciones
        .where((c) => favoritos.contains(c.id))
        .toList();

    // Si hay filtro de himnario, aplicarlo
    if (widget.himnarioFiltro != null) {
      cancionesFavoritas = cancionesFavoritas
          .where((c) => c.himnario == widget.himnarioFiltro)
          .toList();
    }

    // Agrupar por himnario si no hay filtro específico
    Map<String, List<Cancion>> favoritosPorHimnario = {};
    if (widget.himnarioFiltro == null) {
      for (var cancion in cancionesFavoritas) {
        if (!favoritosPorHimnario.containsKey(cancion.himnario)) {
          favoritosPorHimnario[cancion.himnario] = [];
        }
        favoritosPorHimnario[cancion.himnario]!.add(cancion);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.himnarioFiltro != null
              ? 'Favoritos - ${widget.himnarioFiltro}'
              : 'Favoritos',
          style: const TextStyle(
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
        actions: widget.mostrarBotonCerrar
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ]
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFF6FF), Color(0xFFF5F3FF), Color(0xFFFAF5FF)],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                )
              : cancionesFavoritas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.himnarioFiltro != null
                            ? 'No tienes favoritos en ${widget.himnarioFiltro}'
                            : 'No tienes favoritos aún',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.himnarioFiltro != null
                            ? 'Agrega canciones de ${widget.himnarioFiltro}\na favoritos para verlas aquí'
                            : 'Agrega canciones a favoritos desde\nla pantalla principal o desde un himnario',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.himnarioFiltro == null) ...[
                        // Contador total sin título principal
                        Text(
                          '${cancionesFavoritas.length} canción${cancionesFavoritas.length != 1 ? 'es' : ''} favorita${cancionesFavoritas.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Mostrar favoritos agrupados por himnario en secciones colapsables
                        ...favoritosPorHimnario.entries.map((entry) {
                          final nombreHimnario = entry.key;
                          final cancionesDelHimnario = entry.value;
                          // Inicializar como expandido por defecto
                          if (!_expandedSections.containsKey(nombreHimnario)) {
                            _expandedSections[nombreHimnario] = true;
                          }
                          return _buildCollapsibleSection(
                            nombreHimnario,
                            cancionesDelHimnario,
                          );
                        }),
                      ] else ...[
                        // Vista filtrada por himnario específico
                        Text(
                          '${cancionesFavoritas.length} canción${cancionesFavoritas.length != 1 ? 'es' : ''} favorita${cancionesFavoritas.length != 1 ? 's' : ''} en ${widget.himnarioFiltro}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...cancionesFavoritas.map((cancion) {
                          final himnarioCancion = himnarios.firstWhere(
                            (h) => h.nombre == cancion.himnario,
                          );
                          return CancionCard(
                            cancion: cancion,
                            himnario: himnarioCancion,
                            isFavorite: true,
                            mostrarHimnario: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CancionScreen(
                                    cancion: cancion,
                                    himnario: himnarioCancion,
                                    favoritos: favoritos,
                                    onToggleFavorito: _toggleFavorito,
                                  ),
                                ),
                              );
                            },
                            onToggleFavorito: () => _toggleFavorito(cancion.id),
                          );
                        }),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
