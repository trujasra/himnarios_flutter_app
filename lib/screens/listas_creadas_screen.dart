import 'package:flutter/foundation.dart';
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
    
    // Recargar listas cuando se vuelva a esta pantalla
    // pero solo si no estamos ya cargando
    if (!_isLoading) {
      _cargarListas();
    }
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
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar nombre de la lista'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Nombre de la lista',
                border: const OutlineInputBorder(),
                helperText: '${controller.text.length}/50',
                counterText: '',
              ),
              autofocus: true,
              maxLength: 50,
              onChanged: (value) {
                setState(() {}); // Actualizar el contador
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final nombre = controller.text.trim();
                  if (nombre.isNotEmpty && nombre.length <= 50) {
                    Navigator.pop(context, nombre);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
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
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      // Cargar listas y conteos en paralelo
      final results = await Future.wait([
        _cancionesService.getListas(),
        _cancionesService.getConteoCancionesPorLista(),
      ]);

      if (!mounted) return;
      
      final listas = results[0] as List<Map<String, dynamic>>;
      final conteos = results[1] as Map<int, int>;
      
      // Asegurar que todas las listas tengan un conteo, aunque sea 0
      final conteosActualizados = <int, int>{};
      for (var lista in listas) {
        final idLista = lista['id_lista'] as int;
        conteosActualizados[idLista] = conteos[idLista] ?? 0;
      }
      
      // Debug: Verificar las listas y sus conteos
      if (kDebugMode) {
        print('=== Listas y Conteos ===');
        print('Total de listas: ${listas.length}');
        for (var lista in listas) {
          final idLista = lista['id_lista'] as int;
          final nombreLista = lista['nombre'] as String;
          final cantidad = conteosActualizados[idLista] ?? 0;
          print('Lista: "$nombreLista" (ID: $idLista) - Canciones: $cantidad');
        }
        print('=======================');
      }

      if (mounted) {
        setState(() {
          _listas = listas;
          _conteosCanciones = conteosActualizados;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando listas: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackBar.showError(context, 'Error al cargar las listas');
      }
    }
  }

  // Método para obtener el color específico según el nombre del himnario
  Color _getColorForHimnario(String nombre) {
    return DynamicTheme.getColorForHimnarioSync(nombre);
  }

  // Método para obtener el gradiente específico según el nombre del himnario
  LinearGradient _getGradientForHimnario(String nombre) {
    return DynamicTheme.getGradientForHimnarioSync(nombre);
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listas.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(6),
              itemCount: _listas.length,
              itemBuilder: (context, index) {
                final lista = _listas[index];
                final cantidadCanciones =
                    _conteosCanciones[lista['id_lista']] ?? 0;

                return GestureDetector(
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    lista['nombre'].toString().toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 30, 45, 59),
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                  if (lista['descripcion'] != null &&
                                      lista['descripcion'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      lista['descripcion'].toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      // Badge de cantidad de canciones
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          '$cantidadCanciones ${cantidadCanciones == 1 ? 'canción' : 'canciones'}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Iconos de acción directos
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Botón de editar
                                GestureDetector(
                                  onTap: () => _editarNombreLista(lista),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.blue.shade600,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Botón de eliminar
                                GestureDetector(
                                  onTap: () => _eliminarLista(lista),
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
