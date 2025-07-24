import 'package:flutter/material.dart';
import '../data/himnarios_data.dart';
import '../data/canciones_data.dart';
import '../models/cancion.dart';
import '../theme/app_theme.dart';
import '../widgets/himnario_card.dart';
import '../widgets/cancion_card.dart';
import '../widgets/search_bar_widget.dart';
import 'himnario_screen.dart';
import 'cancion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String busqueda = '';
  List<String> chipsSeleccionados = [];
  List<int> favoritos = [];

  List<String> get chips {
    final himnariosList = himnarios.map((h) => h.nombre).toList();
    final idiomas = canciones.map((c) => c.idioma).toSet().toList();
    return [...himnariosList, ...idiomas];
  }

  List<Cancion> get cancionesFiltradas {
    return canciones.where((cancion) {
      if (chipsSeleccionados.isNotEmpty) {
        final matchHimnario = chipsSeleccionados.contains(cancion.himnario);
        final matchIdioma = chipsSeleccionados.contains(cancion.idioma);
        if (!matchHimnario && !matchIdioma) return false;
      }
      if (busqueda.isNotEmpty) {
        final busq = busqueda.toLowerCase();
        final coincideNumero = cancion.numero.toString().contains(busq);
        final coincideTexto = cancion.titulo.toLowerCase().contains(busq) ||
            (cancion.tituloSecundario?.toLowerCase().contains(busq) ?? false);
        if (!coincideNumero && !coincideTexto) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void toggleFavorito(int cancionId) {
    setState(() {
      if (favoritos.contains(cancionId)) {
        favoritos.remove(cancionId);
      } else {
        favoritos.add(cancionId);
      }
    });
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    children: [
                      // Título y logo
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
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
                                const Text(
                                  'Himnarios',
                                  style: TextStyle(
                                    fontSize: 22,
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                        onBusquedaChanged: (value) => setState(() => busqueda = value),
                        chips: chips,
                        chipsSeleccionados: chipsSeleccionados,
                        onChipsSeleccionados: (chips) => setState(() => chipsSeleccionados = chips),
                      ),
                    ],
                  ),
                ),
              ),
              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resultados de búsqueda primero
                      if (busqueda.isNotEmpty) ...[
                        Text(
                          'Resultados para "$busqueda"',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
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
                            final himnarioCancion = himnarios.firstWhere((h) => h.nombre == cancion.himnario);
                            return CancionCard(
                              cancion: cancion,
                              himnario: himnarioCancion,
                              isFavorite: favoritos.contains(cancion.id),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CancionScreen(
                                      cancion: cancion,
                                      himnario: himnarioCancion,
                                      favoritos: favoritos,
                                      onToggleFavorito: toggleFavorito,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        const SizedBox(height: 32),
                      ],
                      // Menú de himnarios siempre debajo de los resultados
                      Row(
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
                      ),
                      const SizedBox(height: 16),
                      // Lista de himnarios
                      ...himnarios.map((himnario) => HimnarioCard(
                        himnario: himnario,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HimnarioScreen(
                                himnario: himnario,
                                favoritos: favoritos,
                                onToggleFavorito: toggleFavorito,
                              ),
                            ),
                          );
                        },
                      )),
                      const SizedBox(height: 24),
                      // Canciones favoritas
                      if (favoritos.isNotEmpty) ...[
                        Row(
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
                        ),
                        const SizedBox(height: 12),
                        ...canciones
                            .where((c) => favoritos.contains(c.id))
                            .map((cancion) {
                          final himnarioCancion = himnarios.firstWhere((h) => h.nombre == cancion.himnario);
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
                                    favoritos: favoritos,
                                    onToggleFavorito: toggleFavorito,
                                  ),
                                ),
                              );
                            },
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