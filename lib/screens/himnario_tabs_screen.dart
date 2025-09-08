import 'package:flutter/material.dart';
import '../data/canciones_service.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../widgets/cancion_card.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import 'cancion_screen.dart';
import 'favorito_screen.dart';

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
  late TabController _tabController;
  List<int> _favoritos = [];
  List<Cancion> canciones = [];
  List<Himnario> himnarios = [];
  bool isLoading = true;

  final CancionesService _cancionesService = CancionesService();

  @override
  void initState() {
    super.initState();
    _favoritos = List.from(widget.favoritos);
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
    StatusBarManager.setStatusBarColor(_getColorForHimnario(widget.himnario.nombre));
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
    StatusBarManager.setStatusBarColorWithDelay(_getColorForHimnario(widget.himnario.nombre));
  }

  @override
  void onReturnToScreen() {
    StatusBarManager.setStatusBarColorWithDelay(_getColorForHimnario(widget.himnario.nombre));
    _cargarDatos(); // Recargar datos cuando se regresa a la pantalla
  }

  @override
  void dispose() {
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

  Widget _buildFavoritosTab() {
    final cancionesFavoritas = canciones
        .where((c) => _favoritos.contains(c.id) && c.himnario == widget.himnario.nombre)
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
              Icons.playlist_add,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Listas Creadas',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí aparecerán las listas que crees\ncon canciones de ${widget.himnario.nombre}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implementar crear nueva lista
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad de crear listas próximamente'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear Nueva Lista'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getColorForHimnario(widget.himnario.nombre),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              icon: const Icon(Icons.favorite),
              text: 'Favoritos',
            ),
            Tab(
              icon: const Icon(Icons.playlist_add),
              text: 'Listas Creadas',
            ),
          ],
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildFavoritosTab(),
            _buildListasCreadasTab(),
          ],
        ),
      ),
    );
  }
}
