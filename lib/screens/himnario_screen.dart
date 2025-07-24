import 'package:flutter/material.dart';
import '../data/canciones_data.dart';
import '../models/himnario.dart';
import '../models/cancion.dart';
import '../theme/app_theme.dart';
import '../widgets/cancion_card.dart';
import '../widgets/search_bar_widget.dart';
import 'cancion_screen.dart';
import 'indice_screen.dart';

class HimnarioScreen extends StatefulWidget {
  final Himnario himnario;
  final List<int> favoritos;
  final Function(int) onToggleFavorito;

  const HimnarioScreen({
    super.key,
    required this.himnario,
    required this.favoritos,
    required this.onToggleFavorito,
  });

  @override
  State<HimnarioScreen> createState() => _HimnarioScreenState();
}

class _HimnarioScreenState extends State<HimnarioScreen> {
  String busqueda = '';
  List<String> chipsSeleccionados = [];

  List<String> get chips {
    final idiomas = canciones
      .where((c) => c.himnario == widget.himnario.nombre)
      .map((c) => c.idioma)
      .toSet();
    return idiomas
      .map((idioma) {
        final count = canciones.where((c) => c.himnario == widget.himnario.nombre && c.idioma == idioma).length;
        return '$idioma ($count)';
      })
      .toList();
  }

  List<Cancion> get cancionesDelHimnario {
    return canciones
        .where((c) => c.himnario == widget.himnario.nombre)
        .where((cancion) {
          if (chipsSeleccionados.isNotEmpty) {
            // El chip es 'Idioma (cantidad)', así que solo compara el idioma
            final idiomasSeleccionados = chipsSeleccionados.map((chip) => chip.split(' (').first).toList();
            if (!idiomasSeleccionados.contains(cancion.idioma)) return false;
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
        })
        .toList();
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
              // Header del himnario
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.getGradientForHimnario(widget.himnario.color),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Barra superior con botones
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  widget.himnario.nombre,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  widget.himnario.descripcion,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IndiceScreen(
                                    himnario: widget.himnario,
                                    favoritos: widget.favoritos,
                                    onToggleFavorito: widget.onToggleFavorito,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.list, color: Colors.white),
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
              // Lista de canciones
              Expanded(
                child: cancionesDelHimnario.isEmpty
                    ? const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
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
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: cancionesDelHimnario.length,
                        itemBuilder: (context, index) {
                          final cancion = cancionesDelHimnario[index];
                          return CancionCard(
                            cancion: cancion,
                            himnario: widget.himnario,
                            isFavorite: widget.favoritos.contains(cancion.id),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CancionScreen(
                                    cancion: cancion,
                                    himnario: widget.himnario,
                                    favoritos: widget.favoritos,
                                    onToggleFavorito: widget.onToggleFavorito,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 