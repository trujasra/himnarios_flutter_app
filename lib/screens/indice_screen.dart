import 'package:flutter/material.dart';
import '../data/canciones_data.dart';
import '../models/himnario.dart';
import '../models/cancion.dart';
import '../theme/app_theme.dart';
import '../widgets/cancion_card.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import 'cancion_screen.dart';

class IndiceScreen extends StatefulWidget {
  final Himnario himnario;
  final List<int> favoritos;
  final Function(int) onToggleFavorito;

  const IndiceScreen({
    super.key,
    required this.himnario,
    required this.favoritos,
    required this.onToggleFavorito,
  });

  @override
  State<IndiceScreen> createState() => _IndiceScreenState();
}

class _IndiceScreenState extends State<IndiceScreen> with SingleTickerProviderStateMixin, RouteAwareMixin {
  late TabController _tabController;
  // Estado local de favoritos que se sincroniza con el callback
  late List<int> _favoritos;

  @override
  void initState() {
    super.initState();
    _favoritos = List.from(widget.favoritos); // Copia local del estado
    _tabController = TabController(length: 2, vsync: this);
    // Configurar la barra de estado con el color del himnario
    StatusBarManager.setStatusBarColor(AppTheme.getColorForHimnario(widget.himnario.color));
  }

  @override
  void didUpdateWidget(IndiceScreen oldWidget) {
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
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.getColorForHimnario(widget.himnario.color));
  }

  @override
  void onReturnToScreen() {
    // Configurar la barra de estado cuando regresamos a esta pantalla
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.getColorForHimnario(widget.himnario.color));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Cancion> get cancionesDelHimnario {
    return canciones
        .where((c) => c.himnario == widget.himnario.nombre)
        .toList()
      ..sort((a, b) => a.numero.compareTo(b.numero));
  }

  List<String> get categorias {
    return cancionesDelHimnario
        .map((c) => c.categoria)
        .toSet()
        .toList()
      ..sort();
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
              // Header del índice
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.getGradientForHimnario(widget.himnario.color),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Índice',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.himnario.nombre,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: _getColorForHimnario(widget.himnario.color),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: _getColorForHimnario(widget.himnario.color),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.tag),
                      text: 'Por Número',
                    ),
                    Tab(
                      icon: Icon(Icons.list),
                      text: 'Por Categoría',
                    ),
                  ],
                ),
              ),
              
              // Contenido de los tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNumeroTab(),
                    _buildCategoriaTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumeroTab() {
    return ListView.builder(
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
    );
  }

  Widget _buildCategoriaTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        final cancionesCategoria = cancionesDelHimnario
            .where((c) => c.categoria == categoria)
            .toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                categoria,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ),
            ...cancionesCategoria.map((cancion) => Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: CancionCard(
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
              ),
            )),
          ],
        );
      },
    );
  }

  Color _getColorForHimnario(String color) {
    switch (color) {
      case 'emerald':
        return AppTheme.emeraldColor;
      case 'violet':
        return AppTheme.violetColor;
      case 'amber':
        return AppTheme.amberColor;
      default:
        return AppTheme.primaryColor;
    }
  }
} 