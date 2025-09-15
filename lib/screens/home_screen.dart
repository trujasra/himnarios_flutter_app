import 'package:flutter/material.dart';
import 'package:himnarios_flutter_app/widgets/custom_drawer.dart';
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
  String nombreUsuario =
      "Usuario Invitado"; // valor inicial por defecto// <- aquí puedes cambiar dinámicamente

  String busqueda = '';
  List<String> chipsSeleccionados = [];
  List<int> favoritos = [];
  List<Cancion> canciones = [];
  List<Himnario> himnarios = [];
  List<String> idiomas = [];
  bool isLoading = true;
  List<int> _favoritos = [];

  final CancionesService _cancionesService = CancionesService();

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario(); // <- cargar el nombre desde la DB
    _cargarDatos();
    StatusBarManager.setStatusBarColor(AppTheme.primaryColor);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (favoritos.isNotEmpty && _favoritos.isEmpty) {
      _favoritos = List.from(favoritos);
    }
  }

  @override
  void onEnterScreen() {
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.primaryColor);
  }

  @override
  void onReturnToScreen() {
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.primaryColor);
    // Recargar datos cuando regresamos a la pantalla para reflejar cambios de configuración
    _cargarDatos();
  }

  Future<void> _cargarNombreUsuario() async {
    final usuario = await _cancionesService.getPrimerUsuarioRegistrado();

    String nombre = usuario?.nombre ?? "Usuario Invitado";

    // Capitalizar cada palabra
    nombre = capitalizeWords(nombre);

    setState(() {
      nombreUsuario = nombre;
    });
  }

  /// Función para capitalizar la primera letra de cada palabra
  String capitalizeWords(String text) {
    return text
        .toLowerCase()
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);

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
      setState(() => isLoading = false);
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
    setState(() {
      if (_favoritos.contains(cancionId)) {
        _favoritos.remove(cancionId);
      } else {
        _favoritos.add(cancionId);
      }
    });

    await toggleFavorito(cancionId);
  }

  Widget tituloHimnarios() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppTheme.primaryColor,
              height: 1,
              letterSpacing: 0,
            ),
            children: [
              TextSpan(
                text: '${himnarios.length} ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: himnarios.length == 1
                    ? 'Himnario Disponible'
                    : 'Himnarios Disponibles',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${canciones.length}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
                height: 1,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'canciones',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor.withValues(alpha: 0.8),
                letterSpacing: 0.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget tituloResultados(String busqueda) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            /*gradient: LinearGradient(
              colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(
                  255,
                  25,
                  189,
                  210,
                ).withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],*/
          ),
          child: const Icon(
            Icons.search_rounded,
            color: AppTheme.primaryColor,
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
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppTheme.primaryColor,
                height: 1,
                letterSpacing: 0,
              ),
              children: [
                TextSpan(
                  text: '${cancionesFiltradas.length} ',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text:
                      '${cancionesFiltradas.length == 1 ? ' Resultado' : 'Resultados'} para "$busqueda"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(nombreUsuario: nombreUsuario),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Builder(
                              builder: (context) => IconButton(
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Himnarios  App',
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
                          Image.asset(
                            'assets/images/LogoHimnariosApp.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                            if (busqueda.isNotEmpty) ...[
                              tituloResultados(busqueda),
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
                                    mostrarHimnario: true,
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
                            tituloHimnarios(),
                            const SizedBox(height: 16),
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
