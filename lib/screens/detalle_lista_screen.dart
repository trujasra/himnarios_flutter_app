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
            '¿Estás seguro de que quieres eliminar esta canción de la lista ?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
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
      final cancionesBasicas = await _cancionesService.getCancionesDeLista(
        widget.idLista,
      );

      // Obtener información completa de cada canción
      final List<Cancion> cancionesCompletas = [];
      for (final cancionBasica in cancionesBasicas) {
        final cancionCompleta = await _cancionesService.getCancionPorId(
          cancionBasica.id,
        );
        if (cancionCompleta != null) {
          cancionesCompletas.add(cancionCompleta);
        }
      }

      setState(() {
        _canciones = cancionesCompletas;
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
          widget.nombreLista.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.0,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
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
          : Column(
              children: [
                // Header elegante con información de la lista
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icono de la lista
                     /* Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.queue_music,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      
                      const SizedBox(width: 16),*/
                      
                      // Información de la lista
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*Text(
                              widget.nombreLista,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 30, 45, 59),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),*/
                            Row(
                              children: [
                                Icon(
                                  Icons.music_note,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_canciones.length} ${_canciones.length == 1 ? 'canción' : 'canciones'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Lista de canciones
                Expanded(
                  child: _canciones.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
              padding: const EdgeInsets.all(2),
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

                return Container(
                  margin: const EdgeInsets.only(bottom: 1),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Número de la canción
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
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                cancion.numero.toString(),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Información de la canción
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                // Obtener la canción completa con la letra
                                final cancionCompleta = await _cancionesService
                                    .getCancionPorId(cancion.id);
                                if (!mounted || cancionCompleta == null) return;

                                // Obtener la lista de favoritos
                                final favoritos = await _cancionesService
                                    .getFavoritos();
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
                                        if (await _cancionesService.esFavorito(
                                          id,
                                        )) {
                                          await _cancionesService
                                              .quitarFavorito(id);
                                        } else {
                                          await _cancionesService
                                              .agregarFavorito(id);
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
                                  ),
                                  const SizedBox(height: 2),
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
                                  ),
                                  if (cancion.tituloSecundario != null &&
                                      cancion.tituloSecundario!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      cancion.tituloSecundario!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // Badge de idioma
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getColorForIdioma(
                                            cancion.idioma,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: _getColorForIdioma(
                                              cancion.idioma,
                                            ).withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.language,
                                              size: 10,
                                              color: _getColorForIdioma(
                                                cancion.idioma,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              cancion.idioma,
                                              style: TextStyle(
                                                fontSize: 10,
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
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Iconos de acción
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _mostrarDialogoEliminar(cancion.id),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red.shade600,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
                ),
              ],
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
        return const Color.fromARGB(255, 0, 156, 135); // Verde para Español
      case 'quechua':
        return const Color(0xFF4A90E2); // Azul para Quechua
      default:
        return Colors.grey; // Color por defecto
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
