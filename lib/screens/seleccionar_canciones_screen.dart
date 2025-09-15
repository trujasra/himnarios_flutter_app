import 'package:flutter/material.dart';
import '../data/canciones_service.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import '../widgets/status_bar_manager.dart';
import '../widgets/custom_snackbar.dart';

class SeleccionarCancionesScreen extends StatefulWidget {
  final int? idLista;
  final String? nombreLista;
  final bool mostrarBotonCerrar;

  const SeleccionarCancionesScreen({
    super.key,
    this.idLista,
    this.nombreLista,
    this.mostrarBotonCerrar = false,
  });

  @override
  State<SeleccionarCancionesScreen> createState() =>
      _SeleccionarCancionesScreenState();
}

class _SeleccionarCancionesScreenState extends State<SeleccionarCancionesScreen>
    with SingleTickerProviderStateMixin {
  final CancionesService _cancionesService = CancionesService();
  late TabController _tabController;

  List<Himnario> _himnarios = [];
  Map<String, List<Cancion>> _cancionesPorHimnario = {};
  Set<int> _cancionesEnLista = {};
  Set<int> _cancionesSeleccionadas = {};
  bool _isLoading = true;
  int _cancionesAgregadas = 0;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    StatusBarManager.setStatusBarColor(AppTheme.primaryColor);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      final himnarios = await _cancionesService.getHimnariosCompletos();
      // Cargar canciones de cada himnario
      final Map<String, List<Cancion>> cancionesPorHimnario = {};
      final List<Cancion> todasCanciones = [];
      for (final himnario in himnarios) {
        final canciones = await _cancionesService.getCancionesPorHimnario(
          himnario.nombre,
        );
        cancionesPorHimnario[himnario.nombre] = canciones;
        todasCanciones.addAll(canciones);
      }

      // Cargar canciones que ya están en la lista
      if (widget.idLista != null) {
        final cancionesEnLista = await _cancionesService.getCancionesDeLista(
          widget.idLista!,
        );
        final idsEnLista = cancionesEnLista.map((c) => c.id).toSet();
        setState(() {
          _cancionesEnLista = idsEnLista;
          _cancionesAgregadas = idsEnLista.length;
        });
      }

      setState(() {
        _himnarios = himnarios;
        _cancionesPorHimnario = cancionesPorHimnario;
        _isLoading = false;
      });

      if (_himnarios.isNotEmpty) {
        _tabController = TabController(length: _himnarios.length, vsync: this);
      }
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleCancionEnLista(Cancion cancion) async {
    if (widget.idLista == null) return;

    try {
      if (_cancionesEnLista.contains(cancion.id)) {
        await _cancionesService.quitarCancionDeLista(
          idLista: widget.idLista!,
          idCancion: cancion.id,
        );
        setState(() {
          _cancionesEnLista.remove(cancion.id);
          _cancionesSeleccionadas.remove(cancion.id);
          _cancionesAgregadas--;
        });
      } else {
        await _agregarCancionALista(cancion.id);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Error: $e');
      }
    }
  }

  Future<void> _agregarCancionALista(int idCancion) async {
    if (widget.idLista == null) return;

    try {
      await _cancionesService.agregarCancionALista(
        idLista: widget.idLista!,
        idCancion: idCancion,
      );
      if (mounted) {
        setState(() {
          _cancionesSeleccionadas.add(idCancion);
          _cancionesAgregadas++;
        });
        CustomSnackBar.showSuccess(context, 'Canción agregada a la lista');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Error al agregar canción: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agregar Canciones',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Text(
              'a ${widget.nombreLista}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
        actions: [
          if (_cancionesAgregadas > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$_cancionesAgregadas',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : _himnarios.isEmpty
          ? const Center(child: Text('No hay himnarios disponibles'))
          : Container(
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
              child: Column(
                children: [
                  // Buscador
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      onChanged: (value) => setState(() => _busqueda = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar canciones en todos los himnarios...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _busqueda.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _busqueda = ''),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                  // TabBar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorColor: AppTheme.primaryColor,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      tabs: _himnarios.map((himnario) {
                        final canciones =
                            _cancionesPorHimnario[himnario.nombre] ?? [];
                        final enLista = canciones
                            .where((c) => _cancionesEnLista.contains(c.id))
                            .length;
                        return Tab(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(himnario.nombre),
                              if (enLista > 0)
                                Text(
                                  '$enLista agregadas',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: _himnarios.map((himnario) {
                        final canciones =
                            _cancionesPorHimnario[himnario.nombre] ?? [];
                        return _buildCancionesList(himnario, canciones);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: _cancionesAgregadas > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context, true);
                CustomSnackBar.showSuccess(
                  context,
                  '$_cancionesAgregadas canción${_cancionesAgregadas != 1 ? 'es' : ''} agregada${_cancionesAgregadas != 1 ? 's' : ''} a la lista',
                );
              },
              backgroundColor: Colors.green,
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                'Listo ($_cancionesAgregadas)',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  List<Cancion> _filtrarCanciones(List<Cancion> canciones) {
    if (_busqueda.isEmpty) return canciones;

    return canciones.where((cancion) {
      final busq = _busqueda.toLowerCase();
      return cancion.titulo.toLowerCase().contains(busq) ||
          cancion.numero.toString().contains(busq) ||
          (cancion.tituloSecundario?.toLowerCase().contains(busq) ?? false);
    }).toList();
  }

  Widget _buildCancionesList(Himnario himnario, List<Cancion> canciones) {
    final cancionesFiltradas = _filtrarCanciones(canciones);

    if (cancionesFiltradas.isEmpty) {
      return Center(
        child: Text(
          _busqueda.isEmpty
              ? 'No hay canciones en ${himnario.nombre}'
              : 'No se encontraron canciones con "$_busqueda"',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cancionesFiltradas.length,
      itemBuilder: (context, index) {
        final cancion = cancionesFiltradas[index];
        final estaEnLista = _cancionesEnLista.contains(cancion.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: estaEnLista
                ? Border.all(color: Colors.green.shade400, width: 2)
                : Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _toggleCancionEnLista(cancion),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Número de canción
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: estaEnLista
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: estaEnLista
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cancion.numero.toString(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: estaEnLista
                                ? Colors.green.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Información de la canción
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cancion.titulo,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: estaEnLista
                                  ? Colors.green.shade800
                                  : Colors.grey.shade800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (cancion.tituloSecundario != null &&
                              cancion.tituloSecundario!.isNotEmpty)
                            Text(
                              cancion.tituloSecundario!,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            himnario.nombre,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón de agregar/quitar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: estaEnLista
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: estaEnLista
                              ? Colors.red.shade300
                              : Colors.green.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        estaEnLista ? Icons.remove : Icons.add,
                        color: estaEnLista
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
