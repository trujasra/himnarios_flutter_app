import 'package:flutter/material.dart';
import '../data/canciones_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/route_aware_mixin.dart';
import '../widgets/custom_snackbar.dart';
import 'crear_lista_screen.dart';
import 'detalle_lista_screen.dart' as detalle_lista;

class ListasCreadasScreen extends StatefulWidget {
  final bool mostrarBotonCerrar;
  final Map<String, dynamic>? himnario;

  const ListasCreadasScreen({
    super.key,
    this.mostrarBotonCerrar = false,
    this.himnario,
  });

  @override
  State<ListasCreadasScreen> createState() => _ListasCreadasScreenState();
}

class _ListasCreadasScreenState extends State<ListasCreadasScreen>
    with RouteAwareMixin {
  late Map<String, dynamic> _currentHimnario;
  final CancionesService _cancionesService = CancionesService();
  List<Map<String, dynamic>> _listas = [];
  Map<int, int> _conteosCanciones = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentHimnario = widget.himnario ?? {};
    _cargarListas();
    
    // Usar el color del himnario si está disponible, sino usar el color primario
    final color = widget.himnario != null 
        ? _getColorForHimnario(widget.himnario!['nombre']?.toString() ?? '')
        : AppTheme.primaryColor;
    StatusBarManager.setStatusBarColor(color);
  }

  @override
  void onEnterScreen() {
    final color = widget.himnario != null 
        ? _getColorForHimnario(widget.himnario!['nombre']?.toString() ?? '')
        : AppTheme.primaryColor;
    StatusBarManager.setStatusBarColorWithDelay(color);
  }

  @override
  void onReturnToScreen() {
    final color = widget.himnario != null 
        ? _getColorForHimnario(widget.himnario!['nombre']?.toString() ?? '')
        : AppTheme.primaryColor;
    StatusBarManager.setStatusBarColorWithDelay(color);
    _cargarListas(); // Recargar cuando regrese de otras pantallas
  }

  Future<void> _eliminarLista(Map<String, dynamic> lista) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar lista'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la lista "${lista['nombre']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await _cancionesService.eliminarLista(lista['id_lista'] as int);
        if (mounted) {
          CustomSnackBar.showSuccess(context, 'Lista eliminada correctamente');
          _cargarListas();
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Error al eliminar la lista: $e');
        }
      }
    }
  }

  Future<void> _editarNombreLista(Map<String, dynamic> lista) async {
    final TextEditingController controller = TextEditingController(
      text: lista['nombre'] as String,
    );

    final nuevoNombre = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre de la lista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre de la lista',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nombre = controller.text.trim();
              if (nombre.isNotEmpty) {
                Navigator.pop(context, nombre);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (nuevoNombre != null && nuevoNombre != lista['nombre']) {
      try {
        await _cancionesService.actualizarLista(
          idLista: lista['id_lista'] as int,
          nombre: nuevoNombre,
          descripcion: lista['descripcion'] as String? ?? '',
        );
        if (mounted) {
          CustomSnackBar.showSuccess(
            context,
            'Lista actualizada correctamente',
          );
          _cargarListas();
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Error al actualizar la lista: $e');
        }
      }
    }
  }

  Future<void> _cargarListas() async {
    setState(() => _isLoading = true);

    try {
      final listas = await _cancionesService.getListas();
      final conteos = await _cancionesService.getConteoCancionesPorLista();

      setState(() {
        _listas = listas;
        _conteosCanciones = conteos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando listas: $e');
      setState(() => _isLoading = false);
    }
  }

  // Método para obtener el color específico según el nombre del himnario
  Color _getColorForHimnario(String nombre) {
    try {
      return DynamicTheme.getColorForHimnarioSync(nombre);
    } catch (e) {
      print('Error al obtener color para $nombre: $e');
    }
    return AppTheme.primaryColor;
  }

  // Método para obtener el gradiente específico según el nombre del himnario
  LinearGradient _getGradientForHimnario(String nombre) {
    try {
      // Intentar obtener el gradiente del himnario
      return DynamicTheme.getGradientForHimnarioSync(nombre);
    } catch (e) {
      print('Error al obtener gradiente para $nombre: $e');
    }

    // Si no se encuentra el gradiente o hay un error, usar colores por defecto
    return const LinearGradient(
      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !widget.mostrarBotonCerrar
          ? null
          : AppBar(
              title: const Text(
                'Mis Listas Creadas',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listas.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _listas.length,
              itemBuilder: (context, index) {
                final lista = _listas[index];
                final cantidadCanciones =
                    _conteosCanciones[lista['id_lista']] ?? 0;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              detalle_lista.DetalleListaScreen(
                                idLista: lista['id_lista'],
                                nombreLista: lista['nombre'],
                                mostrarBotonCerrar: widget.mostrarBotonCerrar,
                              ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Ícono de lista con gradiente
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: _getGradientForHimnario(
                                _currentHimnario['nombre']?.toString() ??
                                    'Listas',
                              ),
                              borderRadius: BorderRadius.circular(12),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.black..withValues(alpha: 0.2),
                              //     blurRadius: 4,
                              //     offset: const Offset(0, 2),
                              //   ),
                              // ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.playlist_play,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Información de la lista
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lista['nombre'].toString().toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 30, 45, 59),
                                  ),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      0,
                                      156,
                                      135,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                        255,
                                        0,
                                        156,
                                        135,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // const Icon(
                                      //   Icons.music_note,
                                      //   size: 10,
                                      //   color: Color.fromARGB(255, 0, 156, 135),
                                      // ),
                                      // const SizedBox(width: 2),
                                      Text(
                                        '$cantidadCanciones canción${cantidadCanciones != 1 ? 'es' : ''}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color.fromARGB(
                                            255,
                                            0,
                                            156,
                                            135,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botones de acción
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Botón de editar
                              Material(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: () => _editarNombreLista(lista),
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Botón de eliminar
                              Material(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: () => _eliminarLista(lista),
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CrearListaScreen()),
          );
          if (result == true) {
            _cargarListas();
          }
        },
        backgroundColor: _getColorForHimnario(
          widget.himnario?['nombre']?.toString() ?? 'Listas',
        ),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No tienes listas creadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Presiona el botón + para crear una nueva lista',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
