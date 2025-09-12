import 'package:flutter/material.dart';
import '../data/canciones_service.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import '../widgets/custom_snackbar.dart';
import 'seleccionar_canciones_screen.dart';
import 'cancion_screen.dart';

class DetalleListaScreen extends StatefulWidget {
  final int idLista;
  final String nombreLista;
  final bool mostrarBotonCerrar;

  const DetalleListaScreen({
    super.key,
    required this.idLista,
    required this.nombreLista,
    this.mostrarBotonCerrar = false,
  });

  @override
  State<DetalleListaScreen> createState() => _DetalleListaScreenState();
}

class _DetalleListaScreenState extends State<DetalleListaScreen>
    with RouteAwareMixin {
  final CancionesService _cancionesService = CancionesService();
  List<Cancion> _canciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCanciones();
    StatusBarManager.setStatusBarColor(AppTheme.primaryColor);
  }

  @override
  void onEnterScreen() {
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.primaryColor);
  }

  @override
  void onReturnToScreen() {
    StatusBarManager.setStatusBarColorWithDelay(AppTheme.primaryColor);
    _cargarCanciones();
  }

  Future<void> _mostrarDialogoEliminar(int idCancion) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar canción'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar esta canción de la lista?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _cancionesService.eliminarCancionDeLista(
                    widget.idLista,
                    idCancion,
                  );
                  if (mounted) {
                    CustomSnackBar.showSuccess(
                      context,
                      'Canción eliminada de la lista',
                    );
                    _cargarCanciones();
                  }
                } catch (e) {
                  if (mounted) {
                    CustomSnackBar.showError(
                      context,
                      'Error al eliminar la canción: ${e.toString()}',
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _agregarCanciones() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeleccionarCancionesScreen(
          idLista: widget.idLista,
          nombreLista: widget.nombreLista,
          mostrarBotonCerrar: true,
        ),
      ),
    );

    if (result == true && mounted) {
      _cargarCanciones();
    }
  }

  Future<void> _cargarCanciones() async {
    setState(() => _isLoading = true);

    try {
      final canciones = await _cancionesService.getCancionesDeLista(
        widget.idLista,
      );
      setState(() {
        _canciones = canciones;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando canciones: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        CustomSnackBar.showError(context, 'Error al cargar las canciones');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nombreLista,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: widget.mostrarBotonCerrar
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _canciones.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _canciones.length,
              itemBuilder: (context, index) {
                final cancion = _canciones[index];
                // Crear un objeto Himnario temporal para la canción
                final himnario = Himnario(
                  id: 0, // Usar 0 como valor por defecto
                  nombre: cancion.himnario,
                  color: _getColorForHimnario(
                    cancion.himnario,
                  ).value.toRadixString(16).substring(2),
                  colorSecundario: _getGradientForHimnario(
                    cancion.himnario,
                  ).colors.last.value.toRadixString(16).substring(2),
                  colorTexto: '000000', // Negro por defecto
                  canciones: 0,
                  descripcion: '',
                  idiomas: [cancion.idioma],
                );

                return GestureDetector(
                  onTap: () async {
                    // Obtener la canción completa con la letra
                    final cancionCompleta = await _cancionesService
                        .getCancionPorId(cancion.id);
                    if (!mounted || cancionCompleta == null) return;

                    // Obtener la lista de favoritos
                    final favoritos = await _cancionesService.getFavoritos();
                    if (!mounted) return;

                    // Navegar a la pantalla de la canción
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CancionScreen(
                          cancion: cancionCompleta,
                          himnario: himnario,
                          favoritos: favoritos,
                          onToggleFavorito: (id) async {
                            if (await _cancionesService.esFavorito(id)) {
                              await _cancionesService.quitarFavorito(id);
                            } else {
                              await _cancionesService.agregarFavorito(id);
                            }
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    );

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Número de la canción con gradiente
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: _getGradientForHimnario(
                                  cancion.himnario,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  cancion.numero.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Información de la canción
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cancion.titulo,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 30, 45, 59),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // Mostrar himnario
                                  if (cancion.himnario.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      cancion.himnario,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getColorForHimnario(
                                          cancion.himnario,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],

                                  // Badge de idioma
                                  if (cancion.idioma.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getColorForIdioma(
                                          cancion.idioma,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _getColorForIdioma(
                                            cancion.idioma,
                                          ).withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.language,
                                            size: 12,
                                            color: _getColorForIdioma(
                                              cancion.idioma,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            cancion.idioma,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: _getColorForIdioma(
                                                cancion.idioma,
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Botón de eliminar
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  _mostrarDialogoEliminar(cancion.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarCanciones,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Método para obtener el color según el idioma
  Color _getColorForIdioma(String idioma) {
    switch (idioma.toLowerCase()) {
      case 'aymara':
        return const Color.fromARGB(255, 187, 113, 1);
      case 'español':
        return const Color(0xFF1E6F5C);
      case 'quechua':
        return const Color(0xFF6C63FF);
      case 'portugués':
        return const Color(0xFFE23E57);
      case 'inglés':
        return const Color(0xFF3B44F6);
      default:
        return Colors.grey;
    }
  }

  // Método para obtener el color del himnario
  Color _getColorForHimnario(String nombre) {
    return DynamicTheme.getColorForHimnarioSync(nombre);
  }

  // Método para obtener el gradiente según el himnario
  LinearGradient _getGradientForHimnario(String nombre) {
    return DynamicTheme.getGradientForHimnarioSync(nombre);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Icon(Icons.music_off, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay canciones en esta lista',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Presiona el botón + para agregar canciones',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
