import 'package:flutter/material.dart';
import '../data/canciones_service.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../widgets/cancion_card.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import 'cancion_screen.dart';
import 'listas_creadas_screen.dart';

class HimnarioTabsScreen extends StatefulWidget {
  final Himnario himnario;
  final List<int> favoritos;
  final Function(int) onToggleFavorito;

  const HimnarioTabsScreen({
    super.key,
    required this.himnario,
    required this.favoritos,
    required this.onToggleFavorito,
  });

  @override
  State<HimnarioTabsScreen> createState() => _HimnarioTabsScreenState();
}

class _HimnarioTabsScreenState extends State<HimnarioTabsScreen>
    with SingleTickerProviderStateMixin, RouteAwareMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: 0,
  );
  List<int> _favoritos = [];
  List<Cancion> canciones = [];
  List<Himnario> himnarios = [];
  bool isLoading = true;

  final CancionesService _cancionesService = CancionesService();

  @override
  void initState() {
    super.initState();
    _favoritos = List.from(widget.favoritos);
    _tabController.addListener(_onTabChanged);
    _cargarDatos();
    // Establecer el color del StatusBar según el himnario
    StatusBarManager.setStatusBarColor(
      _getColorForHimnario(widget.himnario.nombre),
    );
  }

  @override
  void didUpdateWidget(HimnarioTabsScreen oldWidget) {
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
    // Recargar datos para reflejar cambios de configuración
    _cargarDatos();
  }

  void _onTabChanged() {
    // Actualizar el color del StatusBar cuando cambie de tab
    StatusBarManager.setStatusBarColor(
      _getColorForHimnario(widget.himnario.nombre),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
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
        _favoritos = favoritosData;
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => isLoading = false);
    }
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

  Color _getColorForHimnario(String nombre) {
    // Usar colores dinámicos desde cache o fallback a estáticos
    return DynamicTheme.getColorForHimnarioSync(nombre);
  }

  LinearGradient _getGradientForHimnario(String nombre) {
    // Usar gradientes dinámicos desde cache o fallback a estáticos
    return DynamicTheme.getGradientForHimnarioSync(nombre);
  }

  Widget _buildFavoritosTab() {
    final cancionesFavoritas = canciones
        .where(
          (c) =>
              _favoritos.contains(c.id) && c.himnario == widget.himnario.nombre,
        )
        .toList();

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: _getColorForHimnario(widget.himnario.nombre),
        ),
      );
    }

    if (cancionesFavoritas.isEmpty) {
      return Center(
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
              'No tienes favoritos en ${widget.himnario.nombre}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega canciones a favoritos para verlas aquí',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: cancionesFavoritas.length,
      itemBuilder: (context, index) {
        final cancion = cancionesFavoritas[index];
        return CancionCard(
          cancion: cancion,
          himnario: widget.himnario,
          isFavorite: true,
          mostrarHimnario: false,
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
    );
  }

  Widget _buildListasCreadasTab() {
    return ListasCreadasScreen(
      himnario: {
        'id': widget.himnario.id,
        'nombre': widget.himnario.nombre,
        'color': widget.himnario.color,
        'colorSecundario': widget.himnario.colorSecundario,
        'colorHex': widget.himnario.colorHex,
        'colorDarkHex': widget.himnario.colorDarkHex,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.himnario.nombre,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: _getColorForHimnario(widget.himnario.nombre),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: _getGradientForHimnario(widget.himnario.nombre),
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
        child: Column(
          children: [
            // TabBar con estilo similar a cancion_screen
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                labelColor: _getColorForHimnario(widget.himnario.nombre),
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: _getColorForHimnario(widget.himnario.nombre),
                indicatorWeight: 3,
                // labelStyle: const TextStyle(
                //   fontFamily: 'Poppins',
                //   fontWeight: FontWeight.w600,
                //   fontSize: 14,
                // ),
                // unselectedLabelStyle: const TextStyle(
                //   fontFamily: 'Poppins',
                //   fontWeight: FontWeight.w500,
                //   fontSize: 14,
                // ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 18),
                        const SizedBox(width: 6),
                        const Text('FAVORITOS'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.playlist_add, size: 18),
                        const SizedBox(width: 6),
                        const Text('LISTAS CREADAS'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildFavoritosTab(), _buildListasCreadasTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
