import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'data_cala.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('himnarios.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Par_Idioma (
        id_idioma INTEGER PRIMARY KEY,
        descripcion TEXT,
        estado_registro BOOLEAN,
        fecha_registro TEXT,
        usuario_registro TEXT,
        fecha_modificacion TEXT,
        usuario_modificacion TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE Par_Tipo_Himnario (
        id_tipo_himnario INTEGER PRIMARY KEY,
        nombre TEXT,
        descripcion TEXT,
        estado_registro BOOLEAN,
        fecha_registro TEXT,
        usuario_registro TEXT,
        fecha_modificacion TEXT,
        usuario_modificacion TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE Usuario (
        id_usuario INTEGER PRIMARY KEY,
        nombre TEXT,
        estado_registro BOOLEAN,
        fecha_registro TEXT,
        usuario_registro TEXT,
        fecha_modificacion TEXT,
        usuario_modificacion TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE Cancion (
        id_cancion INTEGER PRIMARY KEY,
        id_idioma INTEGER,
        id_tipo_himnario INTEGER,
        numero TEXT,
        titulo TEXT,
        orden INTEGER,
        estado_registro BOOLEAN,
        fecha_registro TEXT,
        usuario_registro TEXT,
        fecha_modificacion TEXT,
        usuario_modificacion TEXT,
        FOREIGN KEY (id_idioma) REFERENCES Par_Idioma(id_idioma),
        FOREIGN KEY (id_tipo_himnario) REFERENCES Par_Tipo_Himnario(id_tipo_himnario)
      );
    ''');
    await db.execute('''
      CREATE TABLE Letra (
        id_letra INTEGER PRIMARY KEY,
        id_cancion INTEGER,
        descripcion TEXT,
        estado_registro BOOLEAN,
        fecha_registro TEXT,
        usuario_registro TEXT,
        fecha_modificacion TEXT,
        usuario_modificacion TEXT,
        FOREIGN KEY (id_cancion) REFERENCES Cancion(id_cancion)
      );
    ''');
    await db.execute('''
      CREATE TABLE Favoritos (
        id_favorito INTEGER PRIMARY KEY,
        id_cancion INTEGER,
        estado_registro BOOLEAN,
        fecha_registro TEXT,
        usuario_registro TEXT,
        fecha_modificacion TEXT,
        usuario_modificacion TEXT,
        FOREIGN KEY (id_cancion) REFERENCES Cancion(id_cancion)
      );
    ''');
    await db.execute('''
      CREATE TABLE Lista (
        id_lista INTEGER PRIMARY KEY,
        nombre TEXT,
        descripcion TEXT,
        estado_registro BOOLEAN,
        fecha_registro TEXT,
        usuario_registro TEXT,
        fecha_modificacion TEXT,
        usuario_modificacion TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE Lista_Cancion (
        id_lista_cancion INTEGER PRIMARY KEY,
        id_lista INTEGER,
        id_cancion INTEGER,
        estado_registro BOOLEAN,
        fecha_registro TEXT,
        usuario_registro TEXT,
        fecha_modificacion TEXT,
        usuario_modificacion TEXT,
        FOREIGN KEY (id_lista) REFERENCES Lista(id_lista),
        FOREIGN KEY (id_cancion) REFERENCES Cancion(id_cancion)
      );
    ''');
  }

  // Ejemplo: insertar idioma
  Future<int> insertIdioma(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('Par_Idioma', row);
  }

  /// Inserta los idiomas Español y Aymara en la tabla Par_Idioma
  Future<void> poblarIdiomasIniciales() async {
    final db = await instance.database;
    
    // Verificar si ya existen los idiomas
    final idiomasExistentes = await db.query('Par_Idioma', where: 'id_idioma IN (?, ?)', whereArgs: [1, 2]);
    if (idiomasExistentes.isNotEmpty) {
      print('Los idiomas ya existen en la base de datos');
      return;
    }
    
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    await db.insert('Par_Idioma', {
      'id_idioma': 1,
      'descripcion': 'Español',
      'estado_registro': 1,
      'fecha_registro': now,
      'usuario_registro': 'ramiro.trujillo',
      'fecha_modificacion': null,
      'usuario_modificacion': null,
    });
    await db.insert('Par_Idioma', {
      'id_idioma': 2,
      'descripcion': 'Aymara',
      'estado_registro': 1,
      'fecha_registro': now,
      'usuario_registro': 'ramiro.trujillo',
      'fecha_modificacion': null,
      'usuario_modificacion': null,
    });
  }

  // Funciones para manejar favoritos
  Future<List<int>> getFavoritos() async {
    final db = await instance.database;
    final result = await db.query(
      'Favoritos',
      columns: ['id_cancion'],
      where: 'estado_registro = ?',
      whereArgs: [1],
    );
    return result.map((row) => row['id_cancion'] as int).toList();
  }

  Future<void> agregarFavorito(int idCancion) async {
    final db = await instance.database;
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    
    // Verificar si ya existe
    final existente = await db.query(
      'Favoritos',
      where: 'id_cancion = ?',
      whereArgs: [idCancion],
    );
    
    if (existente.isEmpty) {
      // Insertar nuevo favorito
      await db.insert('Favoritos', {
        'id_cancion': idCancion,
        'estado_registro': 1,
        'fecha_registro': now,
        'usuario_registro': 'ramiro.trujillo',
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
      print('✅ Favorito agregado: Canción $idCancion');
    } else {
      // Actualizar estado si ya existe
      await db.update(
        'Favoritos',
        {
          'estado_registro': 1,
          'fecha_modificacion': now,
          'usuario_modificacion': 'ramiro.trujillo',
        },
        where: 'id_cancion = ?',
        whereArgs: [idCancion],
      );
      print('✅ Favorito actualizado: Canción $idCancion');
    }
  }

  Future<void> quitarFavorito(int idCancion) async {
    final db = await instance.database;
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    
    await db.update(
      'Favoritos',
      {
        'estado_registro': 0,
        'fecha_modificacion': now,
        'usuario_modificacion': 'ramiro.trujillo',
      },
      where: 'id_cancion = ?',
      whereArgs: [idCancion],
    );
    print('🗑️ Favorito removido: Canción $idCancion');
  }

  Future<bool> esFavorito(int idCancion) async {
    final db = await instance.database;
    final result = await db.query(
      'Favoritos',
      where: 'id_cancion = ? AND estado_registro = ?',
      whereArgs: [idCancion, 1],
    );
    return result.isNotEmpty;
  }

  /// Inserta los himnarios iniciales en la tabla Par_Tipo_Himnario
  Future<void> poblarHimnariosIniciales() async {
    final db = await instance.database;
    
    // Verificar si ya existen los himnarios
    final himnariosExistentes = await db.query('Par_Tipo_Himnario', where: 'id_tipo_himnario IN (?, ?, ?, ?, ?)', whereArgs: [1, 2, 3, 4, 5]);
    if (himnariosExistentes.isNotEmpty) {
      print('Los himnarios ya existen en la base de datos');
      return;
    }
    
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final usuario = 'ramiro.trujillo';
    final himnarios = [
      'Bendicion del Cielo',
      'Coros Cristianos',
      'Cala',
      'LLuvias de Bendición',
      'Poder del Evangelio',
    ];
    for (int i = 0; i < himnarios.length; i++) {
      await db.insert('Par_Tipo_Himnario', {
        'id_tipo_himnario': i + 1,
        'nombre': himnarios[i],
        'descripcion': himnarios[i],
        'estado_registro': 1,
        'fecha_registro': now,
        'usuario_registro': usuario,
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
    }
  }

  // Obtener todos los himnarios con información adicional
  Future<List<Map<String, dynamic>>> getHimnarios() async {
    final db = await instance.database;
    return await db.query('Par_Tipo_Himnario');
  }

  // Obtener himnarios con conteo de canciones por idioma
  Future<List<Map<String, dynamic>>> getHimnariosConDetalles() async {
    final db = await instance.database;
    
    // Primero verificar qué himnarios existen
    final himnariosBasicos = await db.query('Par_Tipo_Himnario');
    print('Himnarios encontrados en BD: ${himnariosBasicos.length}');
    for (var h in himnariosBasicos) {
      print('  - ${h['nombre']} (ID: ${h['id_tipo_himnario']})');
    }
    
    // Consulta simplificada sin GROUP_CONCAT
    final resultado = await db.rawQuery('''
      SELECT 
        th.id_tipo_himnario,
        th.nombre,
        th.descripcion,
        COUNT(c.id_cancion) as total_canciones
      FROM Par_Tipo_Himnario th
      LEFT JOIN Cancion c ON th.id_tipo_himnario = c.id_tipo_himnario AND c.estado_registro = 1
      WHERE th.estado_registro = 1
      GROUP BY th.id_tipo_himnario, th.nombre, th.descripcion
      ORDER BY th.id_tipo_himnario
    ''');
    
    print('Resultado de getHimnariosConDetalles: ${resultado.length} himnarios');
    for (var h in resultado) {
      print('  - ${h['nombre']}: ${h['total_canciones']} canciones');
    }
    
    return resultado;
  }

  // Obtener idiomas disponibles para un himnario específico
  Future<List<String>> getIdiomasPorHimnario(int idHimnario) async {
    final db = await instance.database;
    final resultado = await db.rawQuery('''
      SELECT DISTINCT i.descripcion
      FROM Cancion c
      INNER JOIN Par_Idioma i ON c.id_idioma = i.id_idioma
      WHERE c.id_tipo_himnario = ? AND c.estado_registro = 1
      ORDER BY i.descripcion
    ''', [idHimnario]);
    
    return resultado.map((row) => row['descripcion'] as String).toList();
  }

  /// Inserta canciones de ejemplo para el himnario Cala (Aymara y Español) en las tablas Cancion y Letra
  Future<void> poblarCancionesCala() async {
    final db = await instance.database;
    
    // Verificar si ya existen canciones para Cala
    final cancionesExistentes = await db.query('Cancion', where: 'id_tipo_himnario = ?', whereArgs: [3]); // Cala tiene id_tipo_himnario = 3
    if (cancionesExistentes.isNotEmpty) {
      print('Las canciones de Cala ya existen en la base de datos');
      return;
    }
    
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final usuario = 'ramiro.trujillo';

    // Insertar canciones desde data_cala.dart
    for (var cancion in DataCala.canciones) {
      await db.insert("Cancion", {
        ...cancion,
        'fecha_registro': now,
        'usuario_registro': usuario,
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
    }

    // Insertar letras desde data_cala.dart
    print('DEBUG: Insertando ${DataCala.letras.length} letras');
    for (var letra in DataCala.letras) {
      final result = await db.insert('Letra', {
        ...letra,
        'fecha_registro': now,
        'usuario_registro': usuario,
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
      print('DEBUG: Letra insertada para canción Cala ${letra['id_cancion']}: ID = $result');
    }
  }

  // Métodos para obtener canciones desde la base de datos
  Future<List<Map<String, dynamic>>> getCanciones() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT 
        c.id_cancion,
        c.numero,
        c.titulo,
        c.orden,
        th.nombre as himnario,
        i.descripcion as idioma,
        l.descripcion as letra
      FROM Cancion c
      INNER JOIN Par_Tipo_Himnario th ON c.id_tipo_himnario = th.id_tipo_himnario
      INNER JOIN Par_Idioma i ON c.id_idioma = i.id_idioma
      LEFT JOIN Letra l ON c.id_cancion = l.id_cancion
      WHERE c.estado_registro = 1
      ORDER BY c.id_tipo_himnario, c.numero, c.orden
    ''');
  }

  Future<List<Map<String, dynamic>>> getCancionesPorHimnario(int idHimnario) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        c.id_cancion,
        c.numero,
        c.titulo,
        c.orden,
        th.nombre as himnario,
        i.descripcion as idioma,
        l.descripcion as letra
      FROM Cancion c
      INNER JOIN Par_Tipo_Himnario th ON c.id_tipo_himnario = th.id_tipo_himnario
      INNER JOIN Par_Idioma i ON c.id_idioma = i.id_idioma
      LEFT JOIN Letra l ON c.id_cancion = l.id_cancion
      WHERE c.estado_registro = 1 AND c.id_tipo_himnario = ?
      ORDER BY c.numero, c.orden
    ''', [idHimnario]);
    
    print('DEBUG: getCancionesPorHimnario($idHimnario) - ${result.length} canciones encontradas');
    for (var row in result) {
      print('  - Canción ${row['numero']}: ${row['titulo']} (${row['idioma']}) - Letra: ${row['letra'] != null ? "SÍ" : "NO"}');
    }
    
    return result;
  }

  Future<Map<String, dynamic>?> getCancionPorId(int idCancion) async {
    final db = await instance.database;
    final results = await db.rawQuery('''
      SELECT 
        c.id_cancion,
        c.numero,
        c.titulo,
        c.orden,
        th.nombre as himnario,
        i.descripcion as idioma,
        l.descripcion as letra
      FROM Cancion c
      INNER JOIN Par_Tipo_Himnario th ON c.id_tipo_himnario = th.id_tipo_himnario
      INNER JOIN Par_Idioma i ON c.id_idioma = i.id_idioma
      LEFT JOIN Letra l ON c.id_cancion = l.id_cancion
      WHERE c.estado_registro = 1 AND c.id_cancion = ?
    ''', [idCancion]);
    
    return results.isNotEmpty ? results.first : null;
  }

  // Método para poblar toda la base de datos inicial
  Future<void> poblarBaseDatosInicial() async {
    try {
      await poblarIdiomasIniciales();
      await poblarHimnariosIniciales();
      await poblarCancionesCala();
      print('Base de datos poblada exitosamente');
    } catch (e) {
      print('Error poblando base de datos: $e');
    }
  }

  // Método para repoblar las canciones de Cala (útil cuando se agregan nuevas canciones)
  Future<void> repoblarCancionesCala() async {
    try {
      final db = await instance.database;
      
      // Primero obtener los IDs de las canciones de Cala para eliminar sus letras
      final cancionesCala = await db.query('Cancion', 
        columns: ['id_cancion'], 
        where: 'id_tipo_himnario = ?', 
        whereArgs: [3]
      );
      
      final idsCanciones = cancionesCala.map((c) => c['id_cancion']).toList();
      
      // Eliminar letras de las canciones de Cala
      if (idsCanciones.isNotEmpty) {
        await db.delete('Letra', where: 'id_cancion IN (${List.filled(idsCanciones.length, '?').join(',')})', whereArgs: idsCanciones);
      }
      
      // Eliminar canciones existentes de Cala
      await db.delete('Cancion', where: 'id_tipo_himnario = ?', whereArgs: [3]);
      
      // Poblar nuevamente
      await poblarCancionesCala();
      print('Canciones de Cala repobladas exitosamente');
    } catch (e) {
      print('Error repoblando canciones de Cala: $e');
    }
  }

  // Método para verificar si la base de datos ya está poblada
  Future<bool> isBaseDatosPoblada() async {
    final db = await instance.database;
    final himnarios = await db.query('Par_Tipo_Himnario');
    final idiomas = await db.query('Par_Idioma');
    final canciones = await db.query('Cancion');
    
    return himnarios.isNotEmpty && idiomas.isNotEmpty && canciones.isNotEmpty;
  }
}