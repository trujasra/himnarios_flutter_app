import '../models/cancion.dart';
import '../models/usuario.dart';
import '../models/himnario.dart';
import 'database_helper.dart';

class CancionesService {
  static final CancionesService _instance = CancionesService._internal();
  factory CancionesService() => _instance;
  CancionesService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Obtener el conteo total de canciones de todos los himnarios activos
  Future<int> getTotalCancionesHimnariosActivos() async {
    return await _dbHelper.getTotalCancionesHimnariosActivos();
  }

  Future<Usuario?> getPrimerUsuarioRegistrado() async {
    final db = await _dbHelper
        .database; // Espera el Future para obtener la base de datos
    final List<Map<String, dynamic>> maps = await db.query(
      'Usuario',
      columns: ['nombre', 'estado_registro'],
      where: 'estado_registro = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Usuario(
        nombre: map['nombre'] as String,
        estadoRegistro: map['estado_registro'] as int,
      );
    } else {
      return null;
    }
  }

  // Convertir datos de la base de datos al modelo Cancion
  Cancion _mapToCancion(Map<String, dynamic> data) {
    final letra = data['letra'] ?? '';
    print(
      'DEBUG: Mapeando canción ${data['titulo']} - Letra: ${letra.isNotEmpty ? "SÍ" : "NO"} (${letra.length} caracteres)',
    );

    return Cancion(
      id: data['id_cancion'],
      titulo: data['titulo'] ?? '',
      tituloSecundario: null, // Por ahora no tenemos título secundario en la BD
      numero: data['numero'] ?? 0, // Ya es INTEGER en la BD
      himnario: data['himnario'] ?? '',
      idioma: data['idioma'] ?? '',
      categoria: '', // Por ahora no tenemos categoría en la BD
      letra: letra,
    );
  }

  // Obtener todas las canciones
  Future<List<Cancion>> getCanciones() async {
    try {
      final data = await _dbHelper.getCanciones();
      return data.map((item) => _mapToCancion(item)).toList();
    } catch (e) {
      print('Error obteniendo canciones: $e');
      return [];
    }
  }

  // Obtener canciones por himnario (separadas por idioma)
  Future<List<Cancion>> getCancionesPorHimnario(String nombreHimnario) async {
    try {
      // Primero obtener el ID del himnario
      final himnarios = await _dbHelper.getHimnarios();
      final himnario = himnarios.firstWhere(
        (h) => h['nombre'] == nombreHimnario,
        orElse: () => {'id_tipo_himnario': 0},
      );

      if (himnario['id_tipo_himnario'] == 0) return [];

      final data = await _dbHelper.getCancionesPorHimnario(
        himnario['id_tipo_himnario'],
      );
      final canciones = data.map((item) => _mapToCancion(item)).toList();

      print(
        'DEBUG: Canciones cargadas para $nombreHimnario: ${canciones.length}',
      );
      for (var cancion in canciones.take(3)) {
        print(
          '  - ${cancion.numero}: ${cancion.titulo} (${cancion.idioma}) - Letra: ${cancion.letra.isNotEmpty ? "SÍ" : "NO"}',
        );
      }

      // Ordenar por número y luego por idioma
      canciones.sort((a, b) {
        if (a.numero != b.numero) {
          return a.numero.compareTo(b.numero);
        }
        return a.idioma.compareTo(b.idioma);
      });

      return canciones;
    } catch (e) {
      print('Error obteniendo canciones por himnario: $e');
      return [];
    }
  }

  // Búsqueda optimizada de canciones por himnario con filtros
  Future<List<Cancion>> buscarCancionesPorHimnario(
    String nombreHimnario, {
    String? busqueda,
    List<String>? idiomas,
    int? limit,
  }) async {
    try {
      // Obtener el ID del himnario
      final himnarios = await _dbHelper.getHimnarios();
      final himnario = himnarios.firstWhere(
        (h) => h['nombre'] == nombreHimnario,
        orElse: () => {'id_tipo_himnario': 0},
      );

      if (himnario['id_tipo_himnario'] == 0) return [];

      final data = await _dbHelper.buscarCancionesPorHimnario(
        himnario['id_tipo_himnario'],
        busqueda: busqueda,
        idiomas: idiomas,
        limit: limit,
      );

      return data.map((item) => _mapToCancion(item)).toList();
    } catch (e) {
      print('Error en búsqueda optimizada: $e');
      return [];
    }
  }

  // Búsqueda global optimizada
  Future<List<Cancion>> buscarCanciones({
    String? busqueda,
    List<String>? himnarios,
    List<String>? idiomas,
    int? limit,
  }) async {
    try {
      final data = await _dbHelper.buscarCanciones(
        busqueda: busqueda,
        himnarios: himnarios,
        idiomas: idiomas,
        limit: limit,
      );

      return data.map((item) => _mapToCancion(item)).toList();
    } catch (e) {
      print('Error en búsqueda global: $e');
      return [];
    }
  }

  // Obtener una canción específica por ID
  Future<Cancion?> getCancionPorId(int id) async {
    try {
      final data = await _dbHelper.getCancionPorId(id);
      if (data != null) {
        return _mapToCancion(data);
      }
      return null;
    } catch (e) {
      print('Error obteniendo canción por ID: $e');
      return null;
    }
  }

  // Búsqueda rápida por número en un himnario específico
  Future<List<Cancion>> buscarPorNumero(
    String nombreHimnario,
    int numero,
  ) async {
    try {
      // Obtener el ID del himnario
      final himnarios = await _dbHelper.getHimnarios();
      final himnario = himnarios.firstWhere(
        (h) => h['nombre'] == nombreHimnario,
        orElse: () => {'id_tipo_himnario': 0},
      );

      if (himnario['id_tipo_himnario'] == 0) return [];

      final data = await _dbHelper.buscarCancionesPorHimnario(
        himnario['id_tipo_himnario'],
        busqueda: numero.toString(),
        limit: 10,
      );

      return data.map((item) => _mapToCancion(item)).toList();
    } catch (e) {
      print('Error en búsqueda por número: $e');
      return [];
    }
  }

  // Obtener idiomas únicos
  Future<List<String>> getIdiomas() async {
    try {
      final canciones = await getCanciones();
      return canciones.map((c) => c.idioma).toSet().toList();
    } catch (e) {
      print('Error obteniendo idiomas: $e');
      return [];
    }
  }

  // Funciones para manejar favoritos
  Future<List<int>> getFavoritos() async {
    try {
      return await _dbHelper.getFavoritos();
    } catch (e) {
      print('Error obteniendo favoritos: $e');
      return [];
    }
  }

  Future<void> agregarFavorito(int idCancion) async {
    try {
      await _dbHelper.agregarFavorito(idCancion);
    } catch (e) {
      print('Error agregando favorito: $e');
    }
  }

  Future<void> quitarFavorito(int idCancion) async {
    try {
      await _dbHelper.quitarFavorito(idCancion);
    } catch (e) {
      print('Error quitando favorito: $e');
    }
  }

  Future<bool> esFavorito(int idCancion) async {
    try {
      return await _dbHelper.esFavorito(idCancion);
    } catch (e) {
      print('Error verificando favorito: $e');
      return false;
    }
  }

  // Obtener himnarios únicos
  Future<List<String>> getHimnarios() async {
    try {
      final himnarios = await _dbHelper.getHimnarios();
      return himnarios.map((h) => h['nombre'] as String).toList();
    } catch (e) {
      print('Error obteniendo himnarios: $e');
      return [];
    }
  }

  // Convertir datos de la base de datos al modelo Himnario
  Future<Himnario> _mapToHimnario(Map<String, dynamic> data) async {
    // Colores predefinidos para cada himnario
    final colores = {
      'Bendicion del Cielo': {
        'color': 'blue',
        'colorSecundario': 'blue50',
        'colorTexto': 'blue700',
      },
      'Coros Cristianos': {
        'color': 'indigo',
        'colorSecundario': 'indigo50',
        'colorTexto': 'indigo700',
      },
      'Cala': {
        'color': 'violet',
        'colorSecundario': 'violet50',
        'colorTexto': 'violet700',
      },
      'LLuvias de Bendición': {
        'color': 'amber',
        'colorSecundario': 'amber50',
        'colorTexto': 'amber700',
      },
      'Poder del Evangelio': {
        'color': 'emerald',
        'colorSecundario': 'emerald50',
        'colorTexto': 'emerald700',
      },
    };

    final nombre = data['nombre'] as String;
    final colorInfo =
        colores[nombre] ??
        {'color': 'gray', 'colorSecundario': 'gray50', 'colorTexto': 'gray700'};

    // Obtener idiomas reales de la base de datos
    final idiomas = await _dbHelper.getIdiomasPorHimnario(
      data['id_tipo_himnario'],
    );

    // Si no hay idiomas en la BD, usar valores por defecto
    final idiomasFinales = idiomas.isNotEmpty ? idiomas : ['Español'];

    return Himnario(
      id: data['id_tipo_himnario'],
      nombre: nombre,
      color: colorInfo['color']!,
      colorSecundario: colorInfo['colorSecundario']!,
      colorTexto: colorInfo['colorTexto']!,
      canciones: data['total_canciones'] ?? 0,
      descripcion: data['descripcion'] ?? nombre,
      idiomas: idiomasFinales,
      colorHex: data['color'] as String?,
      colorDarkHex: data['color_dark'] as String?,
      imagenFondo: data['imagen_fondo'] as String?,
    );
  }

  // Obtener himnarios con detalles completos
  Future<List<Himnario>> getHimnariosCompletos() async {
    try {
      final data = await _dbHelper.getHimnariosConDetalles();
      final himnarios = <Himnario>[];
      for (var item in data) {
        final himnario = await _mapToHimnario(item);
        himnarios.add(himnario);
      }
      return himnarios;
    } catch (e) {
      print('Error obteniendo himnarios completos: $e');
      return [];
    }
  }

  // Inicializar la base de datos si es necesario
  Future<void> inicializarBaseDatos() async {
    try {
      final yaPoblada = await _dbHelper.isBaseDatosPoblada();
      if (!yaPoblada) {
        print('Poblando base de datos inicial...');
        await _dbHelper.poblarBaseDatosInicial();
      } else {
        print('La base de datos ya está poblada');
        // Actualizar índices en bases de datos existentes
        await _dbHelper.actualizarIndices();
      }
    } catch (e) {
      print('Error inicializando base de datos: $e');
    }
  }

  // Repoblar canciones de Bendicion del Cielo (útil cuando se agregan nuevas canciones)
  Future<void> repoblarCancionesBendicionDelCielo() async {
    try {
      await _dbHelper.repoblarCancionesBendicionDelCielo();
    } catch (e) {
      print('Error repoblando canciones de Bendicion del Cielo: $e');
    }
  }

  // Repoblar canciones de Cala (útil cuando se agregan nuevas canciones)
  Future<void> repoblarCancionesCala() async {
    try {
      await _dbHelper.repoblarCancionesCala();
    } catch (e) {
      print('Error repoblando canciones de Cala: $e');
    }
  }

  // Repoblar canciones de Poder del Evangelio (útil cuando se agregan nuevas canciones)
  Future<void> repoblarCancionesPoder() async {
    try {
      await _dbHelper.repoblarCancionesPoderDelEvangelio();
    } catch (e) {
      print('Error repoblando canciones de Poder del Evangelio: $e');
    }
  }

  // Repoblar canciones de Lluvias de Bendición (útil cuando se agregan nuevas canciones)
  Future<void> repoblarCancionesLluviasDeBendicion() async {
    try {
      await _dbHelper.repoblarCancionesLluviasDeBendicion();
    } catch (e) {
      print('Error repoblando canciones de Lluvias de Bendición: $e');
    }
  }

  // Métodos para configuración de himnarios
  Future<void> actualizarConfiguracionHimnario({
    required int idHimnario,
    String? color,
    String? colorDark,
    String? imagenFondo,
    bool? activo,
  }) async {
    try {
      await _dbHelper.actualizarConfiguracionHimnario(
        idHimnario: idHimnario,
        color: color,
        colorDark: colorDark,
        imagenFondo: imagenFondo,
        activo: activo,
      );
    } catch (e) {
      print('Error actualizando configuración de himnario: $e');
    }
  }

  Future<void> actualizarEstadoHimnario({
    required int idHimnario,
    required bool activo,
  }) async {
    try {
      await _dbHelper.actualizarConfiguracionHimnario(
        idHimnario: idHimnario,
        activo: activo,
      );
    } catch (e) {
      print('Error actualizando estado de himnario: $e');
    }
  }

  Future<Map<String, dynamic>?> getConfiguracionHimnario(int idHimnario) async {
    try {
      return await _dbHelper.getConfiguracionHimnario(idHimnario);
    } catch (e) {
      print('Error obteniendo configuración de himnario: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getConfiguracionHimnarioPorNombre(
    String nombre,
  ) async {
    try {
      return await _dbHelper.getConfiguracionHimnarioPorNombre(nombre);
    } catch (e) {
      print('Error obteniendo configuración de himnario por nombre: $e');
      return null;
    }
  }

  Future<void> inicializarColoresPorDefecto() async {
    await _dbHelper.inicializarColoresPorDefecto();
  }

  // Optimizar la base de datos para mejorar el rendimiento
  Future<void> optimizarBaseDatos() async {
    try {
      await _dbHelper.optimizarBaseDatos();
    } catch (e) {
      print('Error optimizando base de datos desde servicio: $e');
    }
  }

  // ==================== MÉTODOS PARA LISTAS ====================

  // Crear una nueva lista
  Future<int> crearLista({
    required String nombre,
    required String descripcion,
  }) async {
    try {
      return await _dbHelper.crearLista(
        nombre: nombre,
        descripcion: descripcion,
      );
    } catch (e) {
      print('Error creando lista: $e');
      rethrow;
    }
  }

  // Obtener todas las listas
  Future<List<Map<String, dynamic>>> getListas() async {
    try {
      return await _dbHelper.getListas();
    } catch (e) {
      print('Error obteniendo listas: $e');
      return [];
    }
  }

  // Obtener una lista por ID
  Future<Map<String, dynamic>?> getListaPorId(int idLista) async {
    try {
      return await _dbHelper.getListaPorId(idLista);
    } catch (e) {
      print('Error obteniendo lista por ID: $e');
      return null;
    }
  }

  // Actualizar una lista
  Future<void> actualizarLista({
    required int idLista,
    required String nombre,
    required String descripcion,
  }) async {
    try {
      await _dbHelper.actualizarLista(
        idLista: idLista,
        nombre: nombre,
        descripcion: descripcion,
      );
    } catch (e) {
      print('Error actualizando lista: $e');
      rethrow;
    }
  }

  // Eliminar una lista
  Future<void> eliminarLista(int idLista) async {
    try {
      await _dbHelper.eliminarLista(idLista);
    } catch (e) {
      print('Error eliminando lista: $e');
      rethrow;
    }
  }

  // Agregar canción a una lista
  Future<void> agregarCancionALista({
    required int idLista,
    required int idCancion,
  }) async {
    try {
      await _dbHelper.agregarCancionALista(
        idLista: idLista,
        idCancion: idCancion,
      );
    } catch (e) {
      print('Error agregando canción a lista: $e');
      rethrow;
    }
  }

  // Quitar canción de una lista
  Future<void> quitarCancionDeLista({
    required int idLista,
    required int idCancion,
  }) async {
    try {
      await _dbHelper.quitarCancionDeLista(
        idLista: idLista,
        idCancion: idCancion,
      );
    } catch (e) {
      print('Error quitando canción de lista: $e');
      rethrow;
    }
  }

  // Actualizar el orden de una canción en una lista
  Future<void> actualizarOrdenCancionEnLista({
    required int idLista,
    required int idCancion,
    required int nuevoOrden,
  }) async {
    try {
      await _dbHelper.actualizarOrdenCancionEnLista(
        idLista: idLista,
        idCancion: idCancion,
        nuevoOrden: nuevoOrden,
      );
    } catch (e) {
      print('Error actualizando orden de canción en lista: $e');
      rethrow;
    }
  }

  // Obtener canciones de una lista específica
  Future<List<Cancion>> getCancionesDeLista(int idLista) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT c.* 
        FROM Cancion c
        INNER JOIN Lista_Cancion lc ON c.id_cancion = lc.id_cancion
        INNER JOIN Par_Tipo_Himnario th ON c.id_tipo_himnario = th.id_tipo_himnario
        WHERE lc.id_lista = ? 
          AND lc.estado_registro = 1
          AND c.estado_registro = 1
          AND th.estado_registro = 1
        ORDER BY lc.orden ASC, lc.fecha_registro ASC
      ''',
        [idLista],
      );

      return List.generate(maps.length, (i) => _mapToCancion(maps[i]));
    } catch (e) {
      print('Error obteniendo canciones de la lista: $e');
      return [];
    }
  }

  // Eliminar una canción de una lista
  Future<void> eliminarCancionDeLista(int idLista, int idCancion) async {
    final db = await _dbHelper.database;
    await db.delete(
      'Lista_Cancion',
      where: 'id_lista = ? AND id_cancion = ?',
      whereArgs: [idLista, idCancion],
    );
  }

  // Verificar si una canción está en una lista
  Future<bool> cancionEstaEnLista({
    required int idLista,
    required int idCancion,
  }) async {
    try {
      return await _dbHelper.cancionEstaEnLista(
        idLista: idLista,
        idCancion: idCancion,
      );
    } catch (e) {
      print('Error verificando canción en lista: $e');
      return false;
    }
  }

  // Obtener conteo de canciones por lista
  Future<Map<int, int>> getConteoCancionesPorLista() async {
    try {
      return await _dbHelper.getConteoCancionesPorLista();
    } catch (e) {
      print('Error obteniendo conteo de canciones por lista: $e');
      return {};
    }
  }
}
