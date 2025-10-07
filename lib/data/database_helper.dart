import 'package:himnarios_flutter_app/data/data_bendicion_del_cielo.dart';
import 'package:himnarios_flutter_app/data/data_coros_cristianos.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'data_cala.dart';
import 'data_poder_del_evangelio.dart';
import 'data_lluvias_de_bendicion.dart';

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
    print('📁 Ruta base de datos: $path'); // 🔍 Agrega este print
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // No se necesita migración ya que el campo 'orden' está incluido en la creación inicial
    print('Base de datos actualizada de versión $oldVersion a $newVersion');
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
        color TEXT DEFAULT '#295F98',
        color_dark TEXT DEFAULT '#194675',
        imagen_fondo TEXT DEFAULT 'default',
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
        numero INTEGER,
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
        orden INTEGER DEFAULT 0,
        estado_registro BOOLEAN,
        fecha_registro TEXT,
        usuario_registro TEXT,
        fecha_modificacion TEXT,
        usuario_modificacion TEXT,
        FOREIGN KEY (id_lista) REFERENCES Lista(id_lista),
        FOREIGN KEY (id_cancion) REFERENCES Cancion(id_cancion)
      );
    ''');

    // Crear índices para optimizar búsquedas
    await _createIndexes(db);
  }

  /// Crear índices para optimizar las búsquedas
  Future<void> _createIndexes(Database db) async {
    print('Creando índices para optimizar búsquedas...');

    // Índices para la tabla Cancion
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cancion_numero ON Cancion(numero)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cancion_titulo ON Cancion(titulo)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cancion_himnario ON Cancion(id_tipo_himnario)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cancion_idioma ON Cancion(id_idioma)',
    );
    //await db.execute('CREATE INDEX IF NOT EXISTS idx_cancion_estado ON Cancion(estado_registro)');

    // Índices compuestos para búsquedas optimizadas
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cancion_himnario_estado ON Cancion(id_tipo_himnario, estado_registro)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cancion_himnario_numero ON Cancion(id_tipo_himnario, numero)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cancion_estado_numero ON Cancion(estado_registro, numero)',
    );

    // Índices para la tabla Letra con optimización de texto
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_letra_cancion ON Letra(id_cancion)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_letra_descripcion ON Letra(descripcion)',
    );
    //await db.execute('CREATE INDEX IF NOT EXISTS idx_letra_cancion_estado ON Letra(id_cancion, estado_registro)');

    // Índices para la tabla Par_Tipo_Himnario
    //await db.execute('CREATE INDEX IF NOT EXISTS idx_himnario_estado ON Par_Tipo_Himnario(estado_registro)');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_himnario_nombre ON Par_Tipo_Himnario(nombre)',
    );

    // Índices para la tabla Par_Idioma
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_idioma_descripcion ON Par_Idioma(descripcion)',
    );
    //await db.execute('CREATE INDEX IF NOT EXISTS idx_idioma_estado ON Par_Idioma(estado_registro)');

    // Índices para la tabla Favoritos
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_favoritos_cancion ON Favoritos(id_cancion)',
    );
    //await db.execute('CREATE INDEX IF NOT EXISTS idx_favoritos_estado ON Favoritos(estado_registro)');
    //await db.execute('CREATE INDEX IF NOT EXISTS idx_favoritos_cancion_estado ON Favoritos(id_cancion, estado_registro)');

    // Índices para la tabla Lista_Cancion
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lista_cancion_lista ON Lista_Cancion(id_lista)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lista_cancion_cancion ON Lista_Cancion(id_cancion)',
    );
    //await db.execute('CREATE INDEX IF NOT EXISTS idx_lista_cancion_estado ON Lista_Cancion(estado_registro)');

    print('Índices creados exitosamente - Total: 18 índices');
  }

  Future<int> insertIdioma(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('Par_Idioma', row);
  }

  /// Inserta los idiomas Español y Aymara en la tabla Par_Idioma
  Future<void> poblarIdiomasIniciales() async {
    final db = await instance.database;

    // Verificar si ya existen los idiomas
    final idiomasExistentes = await db.query(
      'Par_Idioma',
      where: 'id_idioma IN (?, ?)',
      whereArgs: [1, 2],
    );
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

    // Obtener solo los favoritos que pertenecen a himnarios activos
    final result = await db.rawQuery('''
      SELECT f.id_cancion 
      FROM Favoritos f
      INNER JOIN Cancion c ON f.id_cancion = c.id_cancion
      INNER JOIN Par_Tipo_Himnario th ON c.id_tipo_himnario = th.id_tipo_himnario
      WHERE f.estado_registro = 1 
      AND th.estado_registro = 1
      AND c.estado_registro = 1
    ''');

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
    final himnariosExistentes = await db.query(
      'Par_Tipo_Himnario',
      where: 'id_tipo_himnario IN (?, ?, ?, ?, ?)',
      whereArgs: [1, 2, 3, 4, 5],
    );
    if (himnariosExistentes.isNotEmpty) {
      print('Los himnarios ya existen en la base de datos');
      return;
    }

    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final usuario = 'ramiro.trujillo';
    final himnarios = [
      'Bendición del Cielo',
      'Coros Cristianos',
      'Cala',
      'Lluvias de Bendición',
      'Poder del Evangelio',
    ];
    final descHimnarios = [
      'Alaba, Oh alma mia a Jehová... Sal 146:1',
      'Cantad al Señor canción nueva... Sal. 96.1',
      'Cantad alegres a Dios... Sal. 100:1',
      'Hablando entre vosotros con salmos, con himnos... Ef. 5:19',
      'Cantad a Jehová toda la tierra... 1 Cro. 16:23',
    ];
    final colores = [
      '#EE6B41', // Bendición del Cielo - Naranja
      '#EEB800', // Coros Cristianos - Amarillo
      '#1DC49C', // Cala - Verde esmeralda
      '#A462F0', // Lluvias de Bendición - Púrpura
      '#4FB1FC', // Poder del Evangelio - Azul
    ];
    final coloresDark = [
      '#CA5731', // Bendición del Cielo - Naranja oscuro
      '#FD8D14', // Coros Cristianos- Amarillo oscuro
      '#35A29F', // Cala - Verde esmeralda oscuro
      '#7C3AED', // Lluvias de Bendición - Púrpura oscuro
      '#366AC4', // Poder del Evangelio - Azul oscuro
    ];
    for (int i = 0; i < himnarios.length; i++) {
      await db.insert('Par_Tipo_Himnario', {
        'id_tipo_himnario': i + 1,
        'nombre': himnarios[i],
        'descripcion': descHimnarios[i],
        'color': colores[i],
        'color_dark': coloresDark[i],
        'imagen_fondo': 'default',
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

  /// Obtener el conteo total de canciones de todos los himnarios activos
  Future<int> getTotalCancionesHimnariosActivos() async {
    final db = await instance.database;

    final resultado = await db.rawQuery('''
      SELECT COUNT(c.id_cancion) as total
      FROM Cancion c
      INNER JOIN Par_Tipo_Himnario th ON c.id_tipo_himnario = th.id_tipo_himnario
      WHERE c.estado_registro = 1 AND th.estado_registro = 1
    ''');

    return resultado.first['total'] as int? ?? 0;
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

    // Consulta incluyendo campos de colores
    final resultado = await db.rawQuery('''
      SELECT 
        th.id_tipo_himnario,
        th.nombre,
        th.descripcion,
        th.color,
        th.color_dark,
        th.imagen_fondo,
        COUNT(c.id_cancion) as total_canciones
      FROM Par_Tipo_Himnario th
      LEFT JOIN Cancion c ON th.id_tipo_himnario = c.id_tipo_himnario AND c.estado_registro = 1
      WHERE th.estado_registro = 1
      GROUP BY th.id_tipo_himnario, th.nombre, th.descripcion, th.color, th.color_dark, th.imagen_fondo
      ORDER BY th.id_tipo_himnario
    ''');

    print(
      'Resultado de getHimnariosConDetalles: ${resultado.length} himnarios',
    );
    for (var h in resultado) {
      print('  - ${h['nombre']}: ${h['total_canciones']} canciones');
    }

    return resultado;
  }

  // Obtener idiomas disponibles para un himnario específico
  Future<List<String>> getIdiomasPorHimnario(int idHimnario) async {
    final db = await instance.database;
    final resultado = await db.rawQuery(
      '''
      SELECT DISTINCT i.descripcion
      FROM Cancion c
      INNER JOIN Par_Idioma i ON c.id_idioma = i.id_idioma
      WHERE c.id_tipo_himnario = ? AND c.estado_registro = 1
      ORDER BY i.descripcion
    ''',
      [idHimnario],
    );

    return resultado.map((row) => row['descripcion'] as String).toList();
  }

  /// Inserta canciones para el himnario Bendicion del Cielo (Aymara y Español) en las tablas Cancion y Letra
  Future<void> poblarCancionesBendicionDelCielo() async {
    final db = await instance.database;

    // Verificar si ya existen canciones para Bendicion del Cielo
    final cancionesExistentes = await db.query(
      'Cancion',
      where: 'id_tipo_himnario = ?',
      whereArgs: [1],
    ); // Bendicion del Cielo tiene id_tipo_himnario = 1
    if (cancionesExistentes.isNotEmpty) {
      print(
        'Las canciones de Bendicon del cielo ya existen en la base de datos',
      );
      return;
    }

    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final usuario = 'ramiro.trujillo';

    // Insertar canciones desde data_bendicion_del_cielo.dart
    for (var cancion in DataBendicionDelCielo.canciones) {
      await db.insert("Cancion", {
        ...cancion,
        'fecha_registro': now,
        'usuario_registro': usuario,
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
    }

    // Insertar letras desde data_bendicion_del_cielo.dart
    print('DEBUG: Insertando ${DataBendicionDelCielo.letras.length} letras');
    for (var letra in DataBendicionDelCielo.letras) {
      final result = await db.insert('Letra', {
        ...letra,
        'fecha_registro': now,
        'usuario_registro': usuario,
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
      print(
        'DEBUG: Letra insertada para canción Bendicion del Cielo ${letra['id_cancion']}: ID = $result',
      );
    }
  }

  /// Inserta canciones para el himnario Coros Cristianos (Aymara y Español) en las tablas Cancion y Letra
  Future<void> poblarCancionesCorosCristianos() async {
    final db = await instance.database;

    // Verificar si ya existen canciones para Coros Cristianos
    final cancionesExistentes = await db.query(
      'Cancion',
      where: 'id_tipo_himnario = ?',
      whereArgs: [2],
    ); // Coros Cristianos tiene id_tipo_himnario = 2
    if (cancionesExistentes.isNotEmpty) {
      print('Las canciones de Coros Cristianos ya existen en la base de datos');
      return;
    }

    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final usuario = 'ramiro.trujillo';

    // Insertar canciones desde data_coros_cristianos.dart
    for (var cancion in DataCorosCristianos.canciones) {
      await db.insert("Cancion", {
        ...cancion,
        'fecha_registro': now,
        'usuario_registro': usuario,
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
    }

    // Insertar letras desde data_coros_cristianos.dart
    print('DEBUG: Insertando ${DataCorosCristianos.letras.length} letras');
    for (var letra in DataCorosCristianos.letras) {
      final result = await db.insert('Letra', {
        ...letra,
        'fecha_registro': now,
        'usuario_registro': usuario,
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
      print(
        'DEBUG: Letra insertada para canción Coros Cristianos ${letra['id_cancion']}: ID = $result',
      );
    }
  }

  /// Inserta canciones para el himnario Cala (Aymara y Español) en las tablas Cancion y Letra
  Future<void> poblarCancionesCala() async {
    final db = await instance.database;

    // Verificar si ya existen canciones para Cala
    final cancionesExistentes = await db.query(
      'Cancion',
      where: 'id_tipo_himnario = ?',
      whereArgs: [3],
    ); // Cala tiene id_tipo_himnario = 3
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
      print(
        'DEBUG: Letra insertada para canción Cala ${letra['id_cancion']}: ID = $result',
      );
    }
  }

  /// Inserta canciones para el himnario Poder del Evangelio (Aymara y Español) en las tablas Cancion y Letra
  Future<void> poblarCancionesPoderDelEvangelio() async {
    final db = await instance.database;

    // Verificar si ya existen canciones para Poder del Evangelio
    final cancionesExistentes = await db.query(
      'Cancion',
      where: 'id_tipo_himnario = ?',
      whereArgs: [5],
    ); // Poder del Evangelio tiene id_tipo_himnario = 5
    if (cancionesExistentes.isNotEmpty) {
      print(
        'Las canciones de Poder del Evangelio ya existen en la base de datos',
      );
      return;
    }

    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final usuario = 'ramiro.trujillo';

    // Insertar canciones desde data_poder_del_evangelio.dart
    for (var cancion in DataPoderDelEvangelio.canciones) {
      await db.insert("Cancion", {
        ...cancion,
        'fecha_registro': now,
        'usuario_registro': usuario,
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
    }

    // Insertar letras desde data_poder_del_evangelio.dart
    print('DEBUG: Insertando ${DataPoderDelEvangelio.letras.length} letras');
    for (var letra in DataPoderDelEvangelio.letras) {
      final result = await db.insert('Letra', {
        ...letra,
        'fecha_registro': now,
        'usuario_registro': usuario,
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
      print(
        'DEBUG: Letra insertada para canción Poder del Evangelio ${letra['id_cancion']}: ID = $result',
      );
    }
  }

  /// Inserta canciones para el himnario Lluvias de Bendición (Español) en las tablas Cancion y Letra
  Future<void> poblarCancionesLluviasDeBendicion() async {
    final db = await instance.database;

    // Verificar si ya existen canciones para Lluvias de Bendición
    final cancionesExistentes = await db.query(
      'Cancion',
      where: 'id_tipo_himnario = ?',
      whereArgs: [4],
    ); // Lluvias de Bendición tiene id_tipo_himnario = 4
    if (cancionesExistentes.isNotEmpty) {
      print(
        'Las canciones de Lluvias de Bendición ya existen en la base de datos',
      );
      return;
    }

    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final usuario = 'ramiro.trujillo';

    // Insertar canciones desde data_lluvias_de_bendicion.dart
    for (var cancion in DataLluviasDeBendicion.canciones) {
      await db.insert("Cancion", {
        ...cancion,
        'fecha_registro': now,
        'usuario_registro': usuario,
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
    }

    // Insertar letras desde data_lluvias_de_bendicion.dart
    print('DEBUG: Insertando ${DataLluviasDeBendicion.letras.length} letras');
    for (var letra in DataLluviasDeBendicion.letras) {
      final result = await db.insert('Letra', {
        ...letra,
        'fecha_registro': now,
        'usuario_registro': usuario,
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
      print(
        'DEBUG: Letra insertada para canción Lluvias de Bendición ${letra['id_cancion']}: ID = $result',
      );
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
      ORDER BY c.numero, c.id_tipo_himnario, c.orden
    ''');
  }

  Future<List<Map<String, dynamic>>> getCancionesPorHimnario(
    int idHimnario,
  ) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
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
    ''',
      [idHimnario],
    );

    print(
      'DEBUG: getCancionesPorHimnario($idHimnario) - ${result.length} canciones encontradas',
    );
    for (var row in result) {
      print(
        '  - Canción ${row['numero']}: ${row['titulo']} (${row['idioma']}) - Letra: ${row['letra'] != null ? "SÍ" : "NO"}',
      );
    }

    return result;
  }

  Future<Map<String, dynamic>?> getCancionPorId(int idCancion) async {
    final db = await instance.database;
    final results = await db.rawQuery(
      '''
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
    ''',
      [idCancion],
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Función para normalizar texto (quitar acentos y caracteres especiales)
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ç', 'c');
  }

  /// Función para filtrar resultados por texto normalizado (en Dart, no SQL)
  List<Map<String, dynamic>> _filterByNormalizedText(
    List<Map<String, dynamic>> results,
    String searchText,
  ) {
    final normalizedSearch = _normalizeText(searchText);

    return results.where((item) {
      final titulo = item['titulo']?.toString() ?? '';
      final numero = item['numero']?.toString() ?? '';
      final normalizedTitle = _normalizeText(titulo);

      return numero.contains(searchText) ||
          normalizedTitle.contains(normalizedSearch);
    }).toList();
  }

  /// Búsqueda simple y rápida por número o título (insensible a acentos)
  Future<List<Map<String, dynamic>>> buscarCancionesPorHimnario(
    int idHimnario, {
    String? busqueda,
    List<String>? idiomas,
    int? limit,
  }) async {
    final db = await instance.database;

    // Construir WHERE clause base
    String whereClause = 'c.estado_registro = 1 AND c.id_tipo_himnario = ?';
    List<dynamic> whereArgs = [idHimnario];

    // Agregar filtro de idiomas si se especifica
    if (idiomas != null && idiomas.isNotEmpty) {
      final placeholders = idiomas.map((_) => '?').join(',');
      whereClause += ' AND i.descripcion IN ($placeholders)';
      whereArgs.addAll(idiomas);
    }

    // Si no hay búsqueda, devolver canciones con filtros aplicados
    if (busqueda == null || busqueda.trim().isEmpty) {
      String query =
          '''
        SELECT 
          c.id_cancion,
          c.numero,
          c.titulo,
          c.orden,
          th.nombre as himnario,
          i.descripcion as idioma,
          '' as letra
        FROM Cancion c
        INNER JOIN Par_Tipo_Himnario th ON c.id_tipo_himnario = th.id_tipo_himnario
        INNER JOIN Par_Idioma i ON c.id_idioma = i.id_idioma
        WHERE $whereClause
        ORDER BY c.numero
      ''';

      if (limit != null && limit > 0) {
        query += ' LIMIT $limit';
      }

      return await db.rawQuery(query, whereArgs);
    }

    final cleanSearch = busqueda.trim();

    // Obtener canciones del himnario con filtros aplicados
    String query =
        '''
      SELECT 
        c.id_cancion,
        c.numero,
        c.titulo,
        c.orden,
        th.nombre as himnario,
        i.descripcion as idioma,
        '' as letra
      FROM Cancion c
      INNER JOIN Par_Tipo_Himnario th ON c.id_tipo_himnario = th.id_tipo_himnario
      INNER JOIN Par_Idioma i ON c.id_idioma = i.id_idioma
      WHERE $whereClause
      ORDER BY c.numero
    ''';

    final allResults = await db.rawQuery(query, whereArgs);

    // Filtrar en Dart con normalización de acentos
    final filteredResults = _filterByNormalizedText(allResults, cleanSearch);

    // Aplicar límite si se especifica
    final results = limit != null && limit > 0
        ? filteredResults.take(limit).toList()
        : filteredResults;

    print('🔍 Búsqueda: "$cleanSearch" → ${results.length} resultados');
    return results;
  }

  /// Búsqueda global simple y rápida por número o título (insensible a acentos)
  Future<List<Map<String, dynamic>>> buscarCanciones({
    String? busqueda,
    List<String>? himnarios,
    List<String>? idiomas,
    int? limit,
  }) async {
    final db = await instance.database;

    // Construir WHERE clause
    String whereClause = 'c.estado_registro = 1 AND th.estado_registro = 1';
    List<dynamic> whereArgs = [];

    // No agregar filtro de búsqueda en SQL, se hará en Dart

    // Agregar filtro de himnarios
    if (himnarios != null && himnarios.isNotEmpty) {
      final placeholders = himnarios.map((_) => '?').join(',');
      whereClause += ' AND th.nombre IN ($placeholders)';
      whereArgs.addAll(himnarios);
    }

    // Agregar filtro de idiomas
    if (idiomas != null && idiomas.isNotEmpty) {
      final placeholders = idiomas.map((_) => '?').join(',');
      whereClause += ' AND i.descripcion IN ($placeholders)';
      whereArgs.addAll(idiomas);
    }

    String query =
        '''
      SELECT 
        c.id_cancion,
        c.numero,
        c.titulo,
        c.orden,
        th.nombre as himnario,
        i.descripcion as idioma,
        '' as letra
      FROM Cancion c
      INNER JOIN Par_Tipo_Himnario th ON c.id_tipo_himnario = th.id_tipo_himnario
      INNER JOIN Par_Idioma i ON c.id_idioma = i.id_idioma
      WHERE $whereClause
      ORDER BY c.numero, th.nombre
    ''';

    final allResults = await db.rawQuery(query, whereArgs);

    // Aplicar filtro de búsqueda en Dart si existe
    List<Map<String, dynamic>> filteredResults = allResults;
    if (busqueda != null && busqueda.isNotEmpty) {
      filteredResults = _filterByNormalizedText(allResults, busqueda.trim());
    }

    // Aplicar límite si se especifica
    final result = limit != null && limit > 0
        ? filteredResults.take(limit).toList()
        : filteredResults;

    if (busqueda != null && busqueda.isNotEmpty) {
      print('🔍 Búsqueda global: "$busqueda" → ${result.length} resultados');
    } else {
      print('🔍 Búsqueda global: sin filtros → ${result.length} resultados');
    }
    return result;
  }

  // Método para poblar toda la base de datos inicial
  Future<void> poblarBaseDatosInicial() async {
    try {
      await poblarIdiomasIniciales();
      await poblarHimnariosIniciales();
      await poblarCancionesBendicionDelCielo();
      await poblarCancionesCorosCristianos();
      await poblarCancionesCala();
      await poblarCancionesLluviasDeBendicion();
      await poblarCancionesPoderDelEvangelio();
      print('Base de datos poblada exitosamente');
    } catch (e) {
      print('Error poblando base de datos: $e');
    }
  }

  /// Método para actualizar índices en bases de datos existentes
  Future<void> actualizarIndices() async {
    try {
      final db = await instance.database;
      await _createIndexes(db);
      print('Índices actualizados exitosamente');
    } catch (e) {
      print('Error actualizando índices: $e');
    }
  }

  /// Optimizar la base de datos ejecutando VACUUM y ANALYZE
  Future<void> optimizarBaseDatos() async {
    try {
      final db = await instance.database;

      print('Optimizando base de datos...');

      // VACUUM reorganiza la base de datos para reducir el tamaño del archivo
      await db.execute('VACUUM');
      print('✅ VACUUM completado');

      // ANALYZE actualiza las estadísticas de la base de datos para mejorar el rendimiento de las consultas
      await db.execute('ANALYZE');
      print('✅ ANALYZE completado');

      print('Base de datos optimizada exitosamente');
    } catch (e) {
      print('Error optimizando base de datos: $e');
    }
  }

  // Método para repoblar las canciones de Bendicion del Cielo (útil cuando se agregan nuevas canciones)
  Future<void> repoblarCancionesBendicionDelCielo() async {
    try {
      final db = await instance.database;

      int numeroHimnario = 1; // Bendicion del Cielo

      // Primero obtener los IDs de las canciones de Bendicion del Cielo para eliminar sus letras
      final cancionesBendicionDelCielo = await db.query(
        'Cancion',
        columns: ['id_cancion'],
        where: 'id_tipo_himnario = ?',
        whereArgs: [numeroHimnario],
      );

      final idsCanciones = cancionesBendicionDelCielo
          .map((c) => c['id_cancion'])
          .toList();

      // Eliminar letras de las canciones de Bendicion del Cielo
      if (idsCanciones.isNotEmpty) {
        await db.delete(
          'Letra',
          where:
              'id_cancion IN (${List.filled(idsCanciones.length, '?').join(',')})',
          whereArgs: idsCanciones,
        );
      }

      // Eliminar canciones existentes de Bendicion del Cielo
      await db.delete(
        'Cancion',
        where: 'id_tipo_himnario = ?',
        whereArgs: [numeroHimnario],
      );

      // Poblar nuevamente
      await poblarCancionesBendicionDelCielo();
      print('Canciones de Bendicion del Cielo repobladas exitosamente');
    } catch (e) {
      print('Error repoblando canciones de Bendicion del Cielo: $e');
    }
  }

  // Método para repoblar las canciones de Coro sCristianos (útil cuando se agregan nuevas canciones)
  Future<void> repoblarCancionesCorosCristianos() async {
    try {
      final db = await instance.database;

      // Primero obtener los IDs de las canciones de Coros Cristianos para eliminar sus letras
      final cancionesCorosCristianos = await db.query(
        'Cancion',
        columns: ['id_cancion'],
        where: 'id_tipo_himnario = ?',
        whereArgs: [2],
      );

      final idsCanciones = cancionesCorosCristianos
          .map((c) => c['id_cancion'])
          .toList();

      // Eliminar letras de las canciones de Coros Cristianos
      if (idsCanciones.isNotEmpty) {
        await db.delete(
          'Letra',
          where:
              'id_cancion IN (${List.filled(idsCanciones.length, '?').join(',')})',
          whereArgs: idsCanciones,
        );
      }

      // Eliminar canciones existentes de Coros Cristianos
      await db.delete('Cancion', where: 'id_tipo_himnario = ?', whereArgs: [3]);

      // Poblar nuevamente
      await poblarCancionesCorosCristianos();
      print('Canciones de Coros Cristianos repobladas exitosamente');
    } catch (e) {
      print('Error repoblando canciones de Coros Cristianos: $e');
    }
  }

  // Método para repoblar las canciones de Cala (útil cuando se agregan nuevas canciones)
  Future<void> repoblarCancionesCala() async {
    try {
      final db = await instance.database;

      // Primero obtener los IDs de las canciones de Cala para eliminar sus letras
      final cancionesCala = await db.query(
        'Cancion',
        columns: ['id_cancion'],
        where: 'id_tipo_himnario = ?',
        whereArgs: [3],
      );

      final idsCanciones = cancionesCala.map((c) => c['id_cancion']).toList();

      // Eliminar letras de las canciones de Cala
      if (idsCanciones.isNotEmpty) {
        await db.delete(
          'Letra',
          where:
              'id_cancion IN (${List.filled(idsCanciones.length, '?').join(',')})',
          whereArgs: idsCanciones,
        );
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

  // Método para repoblar las canciones de Poder del Evangelio (útil cuando se agregan nuevas canciones)
  Future<void> repoblarCancionesPoderDelEvangelio() async {
    try {
      final db = await instance.database;

      // Primero obtener los IDs de las canciones de Poder del Evangelio para eliminar sus letras
      final cancionesPoderDelEvangelio = await db.query(
        'Cancion',
        columns: ['id_cancion'],
        where: 'id_tipo_himnario = ?',
        whereArgs: [5],
      );

      final idsCanciones = cancionesPoderDelEvangelio
          .map((c) => c['id_cancion'])
          .toList();

      // Eliminar letras de las canciones de Poder del Evangelio
      if (idsCanciones.isNotEmpty) {
        await db.delete(
          'Letra',
          where:
              'id_cancion IN (${List.filled(idsCanciones.length, '?').join(',')})',
          whereArgs: idsCanciones,
        );
      }

      // Eliminar canciones existentes de Poder del Evangelio
      await db.delete('Cancion', where: 'id_tipo_himnario = ?', whereArgs: [5]);

      // Poblar nuevamente
      await poblarCancionesPoderDelEvangelio();
      print('Canciones de Poder del Evangelio repobladas exitosamente');
    } catch (e) {
      print('Error repoblando canciones de Poder del Evangelio: $e');
    }
  }

  // Método para repoblar las canciones de Lluvias de Bendición (útil cuando se agregan nuevas canciones)
  Future<void> repoblarCancionesLluviasDeBendicion() async {
    try {
      final db = await instance.database;

      // Primero obtener los IDs de las canciones de Lluvias de Bendición para eliminar sus letras
      final cancionesLluviasDeBendicion = await db.query(
        'Cancion',
        columns: ['id_cancion'],
        where: 'id_tipo_himnario = ?',
        whereArgs: [4],
      );

      final idsCanciones = cancionesLluviasDeBendicion
          .map((c) => c['id_cancion'])
          .toList();

      // Eliminar letras de las canciones de Lluvias de Bendición
      if (idsCanciones.isNotEmpty) {
        await db.delete(
          'Letra',
          where:
              'id_cancion IN (${List.filled(idsCanciones.length, '?').join(',')})',
          whereArgs: idsCanciones,
        );
      }

      // Eliminar canciones existentes de Lluvias de Bendición
      await db.delete('Cancion', where: 'id_tipo_himnario = ?', whereArgs: [4]);

      // Poblar nuevamente
      await poblarCancionesLluviasDeBendicion();
      print('Canciones de Lluvias de Bendición repobladas exitosamente');
    } catch (e) {
      print('Error repoblando canciones de Lluvias de Bendición: $e');
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

  // Métodos para configuración de himnarios
  Future<void> actualizarConfiguracionHimnario({
    required int idHimnario,
    String? color,
    String? colorDark,
    String? imagenFondo,
    bool? activo,
  }) async {
    final db = await instance.database;
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    final data = <String, dynamic>{
      'fecha_modificacion': now,
      'usuario_modificacion': 'ramiro.trujillo',
    };

    if (color != null) data['color'] = color;
    if (colorDark != null) data['color_dark'] = colorDark;
    if (imagenFondo != null) data['imagen_fondo'] = imagenFondo;
    if (activo != null) data['estado_registro'] = activo ? 1 : 0;

    await db.update(
      'Par_Tipo_Himnario',
      data,
      where: 'id_tipo_himnario = ?',
      whereArgs: [idHimnario],
    );
    print('✅ Configuración actualizada para himnario ID: $idHimnario');
    print('📊 Filas afectadas: ');
    print('🔧 Datos actualizados: $data');

    // Verificar que se guardó correctamente
    final verificacion = await db.query(
      'Par_Tipo_Himnario',
      where: 'id_tipo_himnario = ?',
      whereArgs: [idHimnario],
    );
    if (verificacion.isNotEmpty) {
      print(
        '✅ Verificación BD - Color: ${verificacion.first['color']}, Color Dark: ${verificacion.first['color_dark']}',
      );
    }
  }

  // Inicializar colores por defecto para himnarios que no los tienen
  Future<void> inicializarColoresPorDefecto() async {
    final db = await instance.database;
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    // Colores por defecto para cada himnario
    final coloresPorDefecto = {
      'Bendición del Cielo': {'color': '#295F98', 'color_dark': '#194675'},
      'Coros Cristianos': {'color': '#EE6B41', 'color_dark': '#CA5731'},
      'Cala': {'color': '#887DF7', 'color_dark': '#675FC5'},
      'LLuvias de Bendición': {'color': '#1DC49C', 'color_dark': '#35A29F'},
      'Poder del Evangelio': {'color': '#4F8DFC', 'color_dark': '#366AC4'},
    };

    for (final entry in coloresPorDefecto.entries) {
      final nombre = entry.key;
      final colores = entry.value;

      // Verificar si el himnario ya tiene colores
      final existing = await db.query(
        'Par_Tipo_Himnario',
        where: 'nombre = ? AND (color IS NULL OR color = "")',
        whereArgs: [nombre],
      );

      if (existing.isNotEmpty) {
        await db.update(
          'Par_Tipo_Himnario',
          {
            'color': colores['color'],
            'color_dark': colores['color_dark'],
            'imagen_fondo': 'default',
            'fecha_modificacion': now,
            'usuario_modificacion': 'sistema',
          },
          where: 'nombre = ?',
          whereArgs: [nombre],
        );
        print('✅ Colores inicializados para: $nombre');
      }
    }
  }

  Future<Map<String, dynamic>?> getConfiguracionHimnario(int idHimnario) async {
    final db = await instance.database;
    final result = await db.query(
      'Par_Tipo_Himnario',
      where: 'id_tipo_himnario = ?',
      whereArgs: [idHimnario],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getConfiguracionHimnarioPorNombre(
    String nombre,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'Par_Tipo_Himnario',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );

    return result.isNotEmpty ? result.first : null;
  }

  // ==================== MÉTODOS CRUD PARA LISTAS ====================

  // Crear una nueva lista
  Future<int> crearLista({
    required String nombre,
    required String descripcion,
  }) async {
    final db = await instance.database;
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    final listaData = {
      'nombre': nombre,
      'descripcion': descripcion,
      'estado_registro': 1,
      'fecha_registro': now,
      'usuario_registro': 'ramiro.trujillo',
      'fecha_modificacion': null,
      'usuario_modificacion': null,
    };

    final id = await db.insert('Lista', listaData);
    print('✅ Lista creada: $nombre (ID: $id)');
    return id;
  }

  // Obtener todas las listas activas
  Future<List<Map<String, dynamic>>> getListas() async {
    final db = await instance.database;
    final result = await db.query(
      'Lista',
      where: 'estado_registro = ?',
      whereArgs: [1],
      orderBy: 'fecha_registro DESC',
    );
    return result;
  }

  // Obtener una lista por ID
  Future<Map<String, dynamic>?> getListaPorId(int idLista) async {
    final db = await instance.database;
    final result = await db.query(
      'Lista',
      where: 'id_lista = ? AND estado_registro = ?',
      whereArgs: [idLista, 1],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Actualizar una lista
  Future<void> actualizarLista({
    required int idLista,
    required String nombre,
    required String descripcion,
  }) async {
    final db = await instance.database;
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    await db.update(
      'Lista',
      {
        'nombre': nombre,
        'descripcion': descripcion,
        'fecha_modificacion': now,
        'usuario_modificacion': 'ramiro.trujillo',
      },
      where: 'id_lista = ?',
      whereArgs: [idLista],
    );
    print('✅ Lista actualizada: $nombre (ID: $idLista)');
  }

  // Eliminar una lista (soft delete)
  Future<void> eliminarLista(int idLista) async {
    final db = await instance.database;
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    // Eliminar todas las canciones de la lista
    await db.update(
      'Lista_Cancion',
      {
        'estado_registro': 0,
        'fecha_modificacion': now,
        'usuario_modificacion': 'ramiro.trujillo',
      },
      where: 'id_lista = ?',
      whereArgs: [idLista],
    );

    // Eliminar la lista
    await db.update(
      'Lista',
      {
        'estado_registro': 0,
        'fecha_modificacion': now,
        'usuario_modificacion': 'ramiro.trujillo',
      },
      where: 'id_lista = ?',
      whereArgs: [idLista],
    );
    print('🗑️ Lista eliminada (ID: $idLista)');
  }

  // Agregar canción a una lista
  Future<void> agregarCancionALista({
    required int idLista,
    required int idCancion,
  }) async {
    final db = await instance.database;
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    // Verificar si ya existe la relación
    final existente = await db.query(
      'Lista_Cancion',
      where: 'id_lista = ? AND id_cancion = ?',
      whereArgs: [idLista, idCancion],
    );

    if (existente.isEmpty) {
      // Obtener el siguiente número de orden para esta lista
      final result = await db.rawQuery(
        'SELECT COALESCE(MAX(orden), 0) + 1 as next_orden FROM Lista_Cancion WHERE id_lista = ?',
        [idLista],
      );
      final nextOrden = (result.first['next_orden'] as int?) ?? 1;

      // Insertar nueva relación con el siguiente número de orden
      await db.insert('Lista_Cancion', {
        'id_lista': idLista,
        'id_cancion': idCancion,
        'orden': nextOrden,
        'estado_registro': 1,
        'fecha_registro': now,
        'usuario_registro': 'ramiro.trujillo',
        'fecha_modificacion': null,
        'usuario_modificacion': null,
      });
      print(
        '✅ Canción agregada a lista (Lista: $idLista, Canción: $idCancion)',
      );
    } else {
      // Reactivar si ya existe pero está inactiva
      await db.update(
        'Lista_Cancion',
        {
          'estado_registro': 1,
          'fecha_modificacion': now,
          'usuario_modificacion': 'ramiro.trujillo',
        },
        where: 'id_lista = ? AND id_cancion = ?',
        whereArgs: [idLista, idCancion],
      );
      print(
        '✅ Canción reactivada en lista (Lista: $idLista, Canción: $idCancion)',
      );
    }
  }

  // Quitar canción de una lista
  Future<void> quitarCancionDeLista({
    required int idLista,
    required int idCancion,
  }) async {
    final db = await instance.database;
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    await db.update(
      'Lista_Cancion',
      {
        'estado_registro': 0,
        'fecha_modificacion': now,
        'usuario_modificacion': 'ramiro.trujillo',
      },
      where: 'id_lista = ? AND id_cancion = ?',
      whereArgs: [idLista, idCancion],
    );
    print(
      '🗑️ Canción removida de lista (Lista: $idLista, Canción: $idCancion)',
    );
  }

  // Actualizar el orden de una canción en una lista
  Future<void> actualizarOrdenCancionEnLista({
    required int idLista,
    required int idCancion,
    required int nuevoOrden,
  }) async {
    final db = await instance.database;
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    await db.update(
      'Lista_Cancion',
      {
        'orden': nuevoOrden,
        'fecha_modificacion': now,
        'usuario_modificacion': 'ramiro.trujillo',
      },
      where: 'id_lista = ? AND id_cancion = ?',
      whereArgs: [idLista, idCancion],
    );

    print(
      '🔄 Orden actualizado para canción (Lista: $idLista, Canción: $idCancion, Nuevo orden: $nuevoOrden)',
    );
  }

  // Obtener canciones de una lista
  Future<List<Map<String, dynamic>>> getCancionesDeLista(int idLista) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      ''' 
      SELECT 
        c.id_cancion,
        c.numero,
        c.titulo,
        c.titulo_secundario,
        c.id_tipo_himnario,
        c.id_idioma,
        c.orden,
        th.nombre as himnario,
        i.descripcion as idioma,
        l.descripcion as letra,
        lc.fecha_registro as fecha_agregada,
        lc.orden as orden_lista
      FROM Lista_Cancion lc
      INNER JOIN Cancion c ON lc.id_cancion = c.id_cancion
      INNER JOIN Par_Tipo_Himnario th ON c.id_tipo_himnario = th.id_tipo_himnario
      INNER JOIN Par_Idioma i ON c.id_idioma = i.id_idioma
      LEFT JOIN Letra l ON c.id_cancion = l.id_cancion
      WHERE lc.id_lista = ? 
        AND lc.estado_registro = 1 
        AND c.estado_registro = 1
      ORDER BY lc.orden ASC, lc.fecha_registro ASC
    ''',
      [idLista],
    );

    return result;
  }

  // Verificar si una canción está en una lista
  Future<bool> cancionEstaEnLista({
    required int idLista,
    required int idCancion,
  }) async {
    final db = await instance.database;
    final result = await db.query(
      'Lista_Cancion',
      where: 'id_lista = ? AND id_cancion = ? AND estado_registro = ?',
      whereArgs: [idLista, idCancion, 1],
    );
    return result.isNotEmpty;
  }

  // Obtener conteo de canciones por lista, considerando solo himnarios activos
  Future<Map<int, int>> getConteoCancionesPorLista() async {
    final db = await instance.database;

    // Primero, obtener todas las listas existentes
    final listas = await db.query('Lista');
    final Map<int, int> conteos = {};

    // Inicializar conteos en 0 para todas las listas
    for (var lista in listas) {
      conteos[lista['id_lista'] as int] = 0;
    }

    // Obtener conteo de canciones activas para cada lista, considerando solo himnarios activos
    final result = await db.rawQuery(''' 
      SELECT 
        lc.id_lista,
        COUNT(lc.id_cancion) as total_canciones
      FROM Lista_Cancion lc
      INNER JOIN Cancion c ON lc.id_cancion = c.id_cancion
      INNER JOIN Par_Tipo_Himnario th ON c.id_tipo_himnario = th.id_tipo_himnario
      WHERE lc.estado_registro = 1 
        AND c.estado_registro = 1
        AND th.estado_registro = 1
      GROUP BY lc.id_lista
    ''');

    // Actualizar los conteos con los valores reales
    for (var row in result) {
      final idLista = row['id_lista'] as int;
      final total = row['total_canciones'] as int;
      conteos[idLista] = total;
    }

    return conteos;
  }
}
