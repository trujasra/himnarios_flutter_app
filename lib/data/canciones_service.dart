import '../models/cancion.dart';
import '../models/himnario.dart';
import 'database_helper.dart';

class CancionesService {
  static final CancionesService _instance = CancionesService._internal();
  factory CancionesService() => _instance;
  CancionesService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Convertir datos de la base de datos al modelo Cancion
  Cancion _mapToCancion(Map<String, dynamic> data) {
    final letra = data['letra'] ?? '';
    print('DEBUG: Mapeando canción ${data['titulo']} - Letra: ${letra.isNotEmpty ? "SÍ" : "NO"} (${letra.length} caracteres)');
    
    return Cancion(
      id: data['id_cancion'],
      titulo: data['titulo'] ?? '',
      tituloSecundario: null, // Por ahora no tenemos título secundario en la BD
      numero: int.tryParse(data['numero']?.toString() ?? '0') ?? 0,
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

      final data = await _dbHelper.getCancionesPorHimnario(himnario['id_tipo_himnario']);
      final canciones = data.map((item) => _mapToCancion(item)).toList();
      
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
      'Bendicion del Cielo': {'color': 'blue', 'colorSecundario': 'blue50', 'colorTexto': 'blue700'},
      'Coros Cristianos': {'color': 'indigo', 'colorSecundario': 'indigo50', 'colorTexto': 'indigo700'},
      'Cala': {'color': 'violet', 'colorSecundario': 'violet50', 'colorTexto': 'violet700'},
      'LLuvias de Bendición': {'color': 'amber', 'colorSecundario': 'amber50', 'colorTexto': 'amber700'},
      'Poder del Evangelio': {'color': 'emerald', 'colorSecundario': 'emerald50', 'colorTexto': 'emerald700'},
    };

    final nombre = data['nombre'] as String;
    final colorInfo = colores[nombre] ?? {'color': 'gray', 'colorSecundario': 'gray50', 'colorTexto': 'gray700'};
    
    // Obtener idiomas reales de la base de datos
    final idiomas = await _dbHelper.getIdiomasPorHimnario(data['id_tipo_himnario']);
    
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
  Future<void> repoblarCancionesPoderDelEvangelio() async {
    try {
      await _dbHelper.repoblarCancionesPoderDelEvangelio();
    } catch (e) {
      print('Error repoblando canciones de Poder del Evangelio: $e');
    }
  }
} 