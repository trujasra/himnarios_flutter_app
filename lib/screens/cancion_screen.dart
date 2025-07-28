import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../data/canciones_service.dart';

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

class _CancionScreenState extends State<CancionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  List<Cancion>? _versionesCancion;

  @override
  void initState() {
    super.initState();
    _cargarVersionesCancion();
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
    final todasLasCanciones = await cancionesService.getCancionesPorHimnario(widget.cancion.himnario);
    
    print('DEBUG: Todas las canciones del himnario: ${todasLasCanciones.length}');
    for (var c in todasLasCanciones) {
      print('  - Canción ${c.numero}: ${c.titulo} (${c.idioma})');
    }
    
    // Buscar todas las versiones de la canción actual (mismo número)
    final versiones = todasLasCanciones.where((c) => c.numero == widget.cancion.numero).toList();
    
    print('DEBUG: Buscando canción número ${widget.cancion.numero}');
    print('DEBUG: Versiones encontradas: ${versiones.length}');
    for (var v in versiones) {
      print('  - Versión: ${v.titulo} (${v.idioma}) - Letra: ${v.letra.isNotEmpty ? "SÍ" : "NO"}');
    }
    
    setState(() {
      _versionesCancion = versiones;
    });

    // Inicializar TabController si hay múltiples versiones
    if (versiones.length > 1) {
      _tabController = TabController(
        length: versiones.length,
        vsync: this,
      );
      
      // Encontrar el índice de la versión actual
      final indexActual = versiones.indexWhere((c) => c.idioma == widget.cancion.idioma);
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
    print('DEBUG: cancionActual - _versionesCancion: ${_versionesCancion?.length ?? "null"}');
    
    if (_versionesCancion != null) {
      if (_versionesCancion!.length > 1) {
        print('DEBUG: Usando versión múltiple: ${_versionesCancion![_currentTabIndex].titulo}');
        return _versionesCancion![_currentTabIndex];
      } else if (_versionesCancion!.length == 1) {
        print('DEBUG: Usando versión única: ${_versionesCancion![0].titulo} - Letra: ${_versionesCancion![0].letra.isNotEmpty ? "SÍ" : "NO"}');
        return _versionesCancion![0];
      }
    }
    print('DEBUG: Usando widget.cancion: ${widget.cancion.titulo} - Letra: ${widget.cancion.letra.isNotEmpty ? "SÍ" : "NO"}');
    return widget.cancion;
  }

  // Verificar si hay múltiples versiones
  bool get tieneMultiplesVersiones => _versionesCancion != null && _versionesCancion!.length > 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF6FF),
              Color(0xFFF5F3FF),
              Color(0xFFFAF5FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con botón de regreso y favorito
              Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.mainGradient,
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
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               '#${cancionActual.numero} - ${cancionActual.titulo}',
                               style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 16,
                                 fontWeight: FontWeight.w500,
                               ),
                               overflow: TextOverflow.ellipsis,
                             ),
                             Text(
                               widget.himnario.nombre,
                               style: const TextStyle(
                                 color: Colors.white70,
                                 fontSize: 14,
                               ),
                               overflow: TextOverflow.ellipsis,
                             ),
                           ],
                         ),
                       ),
                      IconButton(
                        onPressed: () => widget.onToggleFavorito(cancionActual.id),
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
                  padding: const EdgeInsets.all(3.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                               // Letra de la canción
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              cancionActual.letra,
                              style: const TextStyle(
                                fontSize: 22,
                                height: 1.6,
                                color: AppTheme.textColor,
                              ),
                              textAlign: TextAlign.center,
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