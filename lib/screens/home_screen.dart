import 'package:flutter/material.dart';
import '../data/canciones_service.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../widgets/himnario_card.dart';
import '../widgets/cancion_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import 'himnario_screen.dart';
import 'cancion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAwareMixin {
  String busqueda = '';
  List<String> chipsSeleccionados = [];
  List<int> favoritos = [];
  List<Cancion> canciones = [];
  List<Himnario> himnarios = [];
  List<String> idiomas = [];
  bool isLoading = true;
  // Estado local de favoritos que se sincroniza con el callback
  List<int> _favoritos = []; // Inicializar como lista vacía en lugar de late

  final CancionesService _cancionesService = CancionesService();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    // Configurar la barra de estado con el color principal
    StatusBarManager.setStatusBarColor(AppTheme.primaryColor);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializar el estado local de favoritos cuando se cargan los datos
    if (favoritos.isNotEmpty && _favoritos.isEmpty) {
      _favoritos = List.from(favoritos);
    }
  }

  @override
  void onEnterScreen() {
    // Configurar la barra de estado cuando entramos a esta pantalla
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.primaryColor);
  }

  @override
  void onReturnToScreen() {
    // Configurar la barra de estado cuando regresamos a esta pantalla
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.primaryColor);
  }

  Future<void> _cargarDatos() async {
    setState(() {
      isLoading = true;
    });

    try {
      final cancionesData = await _cancionesService.getCanciones();
      final himnariosData = await _cancionesService.getHimnariosCompletos();
      final idiomasData = await _cancionesService.getIdiomas();
      final favoritosData = await _cancionesService.getFavoritos();

      setState(() {
        canciones = cancionesData;
        himnarios = himnariosData;
        idiomas = idiomasData;
        favoritos = favoritosData;
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> get chips {
    final himnariosList = himnarios.map((h) => h.nombre).toList();
    return [...himnariosList, ...idiomas];
  }

  List<Cancion> get cancionesFiltradas {
    return canciones.where((cancion) {
      if (chipsSeleccionados.isNotEmpty) {
        final himnariosSeleccionados = chipsSeleccionados
            .where((chip) => himnarios.any((h) => h.nombre == chip))
            .toList();
        final idiomasSeleccionados = chipsSeleccionados
            .where((chip) => idiomas.contains(chip))
            .toList();

        if (himnariosSeleccionados.isNotEmpty &&
            !himnariosSeleccionados.contains(cancion.himnario)) {
          return false;
        }
        if (idiomasSeleccionados.isNotEmpty &&
            !idiomasSeleccionados.contains(cancion.idioma)) {
          return false;
        }
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

  Future<void> toggleFavorito(int cancionId) async {
    try {
      if (favoritos.contains(cancionId)) {
        await _cancionesService.quitarFavorito(cancionId);
        setState(() {
          favoritos.remove(cancionId);
        });
      } else {
        await _cancionesService.agregarFavorito(cancionId);
        setState(() {
          favoritos.add(cancionId);
        });
      }
    } catch (e) {
      print('Error cambiando favorito: $e');
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

    // Llamar al método original para actualizar la base de datos
    await toggleFavorito(cancionId);
  }

  // Widget título elegante con icono
  Widget tituloHimnarios() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
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
            ],
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 18,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'Himnarios Disponibles',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
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

  // Widget título elegante para "Resultados para"
  Widget tituloResultados(String busqueda) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
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
            ],
          ),
          child: const Icon(
            Icons.search_rounded,
            color: Colors.white,
            size: 20,
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
            'Resultados para "$busqueda"',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
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

  // Widget título elegante para "Favoritas"
  Widget tituloFavoritos() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
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
            'Favoritos',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF6FF), // Blue-50
              Color(0xFFF5F3FF), // Indigo-50
              Color(0xFFFAF5FF), // Purple-50
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header principal
              Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.mainGradient,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: 1.0,
                  ),
                  child: Column(
                    children: [
                      // Título y logo
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Himnarios',
                                  style: const TextStyle(
                                    fontFamily: 'Berkshire Swash',
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  'Colección de cantos sagrados',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${canciones.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                        himnarioColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              // Contenido
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Resultados de búsqueda primero
                            if (busqueda.isNotEmpty) ...[
                              tituloResultados(busqueda),

                              /*Text(
                                'Resultados para "$busqueda"',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                              ),*/
                              const SizedBox(height: 16),
                              if (cancionesFiltradas.isEmpty)
                                const Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Center(
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
                              else
                                ...cancionesFiltradas.map((cancion) {
                                  final himnarioCancion = himnarios.firstWhere(
                                    (h) => h.nombre == cancion.himnario,
                                  );
                                  return CancionCard(
                                    cancion: cancion,
                                    himnario: himnarioCancion,
                                    isFavorite: _favoritos.contains(cancion.id),
                                    mostrarHimnario:
                                        true, // Mostrar himnario en resultados de búsqueda
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CancionScreen(
                                            cancion: cancion,
                                            himnario: himnarioCancion,
                                            favoritos: _favoritos,
                                            onToggleFavorito: _toggleFavorito,
                                          ),
                                        ),
                                      );
                                    },
                                    onToggleFavorito: () =>
                                        _toggleFavorito(cancion.id),
                                  );
                                }),
                              const SizedBox(height: 32),
                            ],
                            // Menú de himnarios siempre debajo de los resultados
                            /*Row(
                              children: [
                                const Icon(
                                  Icons.book,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Himnarios Disponibles',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                              ],
                            ),*/
                            tituloHimnarios(),
                            const SizedBox(height: 16),
                            // Lista de himnarios
                            ...himnarios.map(
                              (himnario) => HimnarioCard(
                                himnario: himnario,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HimnarioScreen(
                                        himnario: himnario,
                                        favoritos: _favoritos,
                                        onToggleFavorito: _toggleFavorito,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Canciones favoritas
                            if (_favoritos.isNotEmpty) ...[
                              tituloFavoritos(),
                              /*Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Favoritas',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                ],
                              ),*/
                              const SizedBox(height: 12),
                              ...canciones
                                  .where((c) => _favoritos.contains(c.id))
                                  .map((cancion) {
                                    final himnarioCancion = himnarios
                                        .firstWhere(
                                          (h) => h.nombre == cancion.himnario,
                                        );
                                    return CancionCard(
                                      cancion: cancion,
                                      himnario: himnarioCancion,
                                      isFavorite: true,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CancionScreen(
                                              cancion: cancion,
                                              himnario: himnarioCancion,
                                              favoritos: _favoritos,
                                              onToggleFavorito: _toggleFavorito,
                                            ),
                                          ),
                                        );
                                      },
                                      onToggleFavorito: () =>
                                          _toggleFavorito(cancion.id),
                                    );
                                  }),
                              const SizedBox(height: 24),
                            ],
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
