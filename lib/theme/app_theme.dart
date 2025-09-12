import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/canciones_service.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(
    255,
    41,
    95,
    152,
  ); // Indigo-600
  static const Color secondaryColor = Color.fromARGB(
    255,
    25,
    70,
    117,
  ); // Purple-600
  static const Color backgroundColor = Color.fromARGB(
    255,
    248,
    250,
    252,
  ); // Slate-50
  static const Color cardColor = Colors.white;
  static const Color textColor = Color.fromARGB(255, 30, 41, 59); // Slate-800

  // Colores de himnarios
  static const Color bendicionColor = Color.fromARGB(255, 238, 107, 65);
  static const Color bendicionDarkColor = Color.fromARGB(
    255,
    202,
    87,
    49,
  ); // Pink-600
  static const Color corosColor = Color.fromARGB(
    255,
    136,
    125,
    247,
  ); // Blue-500
  static const Color corosDarkColor = Color.fromARGB(
    255,
    103,
    95,
    197,
  ); // Blue-600
  static const Color calaColor = Color.fromARGB(
    255,
    29,
    196,
    156,
  ); // 255, 12, 173, 120
  static const Color calaDarkColor = Color.fromARGB(
    255,
    53,
    162,
    159,
  ); // 1,141,97
  static const Color lluviasColor = Color.fromARGB(
    255,
    79,
    141,
    252,
  ); // Amber-500
  static const Color lluviasDarkColor = Color.fromARGB(
    255,
    54,
    106,
    196,
  ); // Amber-600
  static const Color poderColor = Color.fromARGB(255, 238, 184, 0);
  static const Color poderDarkColor = Color.fromARGB(255, 253, 141, 20);

  static const Color statusBarColor = Color.fromARGB(230, 79, 70, 229);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: primaryColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textColor),
        bodyMedium: TextStyle(fontSize: 14, color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // Gradientes para himnarios
  static LinearGradient getGradientForHimnario(String color) {
    switch (color) {
      case 'poder':
        return const LinearGradient(
          colors: [poderColor, poderDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'lluvias':
        return const LinearGradient(
          colors: [lluviasColor, lluviasDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'bendicion':
        return const LinearGradient(
          colors: [bendicionColor, bendicionDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'coros':
        return const LinearGradient(
          colors: [corosColor, corosDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'cala':
        return const LinearGradient(
          colors: [calaColor, calaDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  // Colores para himnarios
  static Color getColorForHimnario(String color) {
    switch (color) {
      case 'poder':
        return poderColor;
      case 'lluvias':
        return lluviasColor;
      case 'bendicion':
        return bendicionColor;
      case 'coros':
        return corosColor;
      case 'cala':
        return calaColor;
      default:
        return primaryColor;
    }
  }

  // Gradiente principal de la app
  static const LinearGradient mainGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mainGradientArribaAbajo = LinearGradient(
    colors: [secondaryColor, primaryColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// Clase para manejar colores dinámicos desde la base de datos
class DynamicTheme {
  static final CancionesService _cancionesService = CancionesService();
  static Map<String, Map<String, dynamic>> _coloresCache = {};

  // Obtener color dinámico para un himnario por nombre
  static Future<Color> getColorForHimnario(String nombreHimnario) async {
    try {
      // Verificar cache primero
      if (_coloresCache.containsKey(nombreHimnario)) {
        final colorHex = _coloresCache[nombreHimnario]!['color'] as String?;
        if (colorHex != null) {
          return Color(
            int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
          );
        }
      }

      // Obtener de la base de datos
      final config = await _cancionesService.getConfiguracionHimnarioPorNombre(
        nombreHimnario,
      );
      if (config != null) {
        _coloresCache[nombreHimnario] = config;
        final colorHex = config['color'] as String?;
        if (colorHex != null) {
          return Color(
            int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
          );
        }
      }

      // Fallback a colores estáticos
      return AppTheme.getColorForHimnario(_mapNombreToKey(nombreHimnario));
    } catch (e) {
      print('Error obteniendo color dinámico: $e');
      return AppTheme.getColorForHimnario(_mapNombreToKey(nombreHimnario));
    }
  }

  // Obtener color oscuro dinámico para un himnario por nombre
  static Future<Color> getDarkColorForHimnario(String nombreHimnario) async {
    try {
      // Verificar cache primero
      if (_coloresCache.containsKey(nombreHimnario)) {
        final colorDarkHex =
            _coloresCache[nombreHimnario]!['color_dark'] as String?;
        if (colorDarkHex != null) {
          return Color(
            int.parse(colorDarkHex.substring(1), radix: 16) + 0xFF000000,
          );
        }
      }

      // Obtener de la base de datos
      final config = await _cancionesService.getConfiguracionHimnarioPorNombre(
        nombreHimnario,
      );
      if (config != null) {
        _coloresCache[nombreHimnario] = config;
        final colorDarkHex = config['color_dark'] as String?;
        if (colorDarkHex != null) {
          return Color(
            int.parse(colorDarkHex.substring(1), radix: 16) + 0xFF000000,
          );
        }
      }

      // Fallback a colores estáticos
      return AppTheme.getColorForHimnario(
        _mapNombreToKey(nombreHimnario),
      ).withOpacity(0.8);
    } catch (e) {
      print('Error obteniendo color oscuro dinámico: $e');
      return AppTheme.getColorForHimnario(
        _mapNombreToKey(nombreHimnario),
      ).withOpacity(0.8);
    }
  }

  // Obtener gradiente dinámico para un himnario
  static Future<LinearGradient> getGradientForHimnario(
    String nombreHimnario,
  ) async {
    try {
      final colorPrimario = await getColorForHimnario(nombreHimnario);
      final colorSecundario = await getDarkColorForHimnario(nombreHimnario);

      return LinearGradient(
        colors: [colorPrimario, colorSecundario],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } catch (e) {
      print('Error obteniendo gradiente dinámico: $e');
      return AppTheme.getGradientForHimnario(_mapNombreToKey(nombreHimnario));
    }
  }

  // Obtener imagen de fondo para un himnario
  static Future<String> getImagenFondoForHimnario(String nombreHimnario) async {
    try {
      // Verificar cache primero
      if (_coloresCache.containsKey(nombreHimnario)) {
        final imagenFondo =
            _coloresCache[nombreHimnario]!['imagen_fondo'] as String?;
        if (imagenFondo != null) {
          return imagenFondo;
        }
      }

      // Obtener de la base de datos
      final config = await _cancionesService.getConfiguracionHimnarioPorNombre(
        nombreHimnario,
      );
      if (config != null) {
        _coloresCache[nombreHimnario] = config;
        final imagenFondo = config['imagen_fondo'] as String?;
        if (imagenFondo != null) {
          return imagenFondo;
        }
      }

      return 'default';
    } catch (e) {
      print('Error obteniendo imagen de fondo: $e');
      return 'default';
    }
  }

  // Limpiar cache (útil cuando se actualizan configuraciones)
  static void clearCache() {
    _coloresCache.clear();
    print('🧹 Cache de colores dinámicos limpiado');
    print('📊 Cache después de limpiar: ${_coloresCache.keys}');
  }

  // Cargar cache inicial con todos los himnarios
  static Future<void> loadCache() async {
    try {
      print('🔄 Iniciando carga de cache...');
      final himnarios = await _cancionesService.getHimnariosCompletos();
      print('📊 Himnarios obtenidos: ${himnarios.length}');

      for (final himnario in himnarios) {
        print('🔍 Procesando himnario: ${himnario.nombre}');
        print('🎨 Color: ${himnario.colorHex}, Dark: ${himnario.colorDarkHex}');

        if (himnario.colorHex != null) {
          _coloresCache[himnario.nombre] = {
            'color': himnario.colorHex,
            'color_dark': himnario.colorDarkHex,
            'imagen_fondo': himnario.imagenFondo,
          };
          print('✅ Agregado al cache: ${himnario.nombre}');
        } else {
          print('⚠️ Sin color personalizado para: ${himnario.nombre}');
        }
      }
      print('✅ Cache de colores dinámicos cargado: ${_coloresCache.keys}');
      print('📊 Total elementos en cache: ${_coloresCache.length}');
    } catch (e) {
      print('❌ Error cargando cache de colores: $e');
    }
  }

  // Mapear nombres de himnarios a keys para fallback
  static String _mapNombreToKey(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'bendición del cielo':
      case 'bendicion del cielo':
        return 'bendicion';
      case 'coros cristianos':
        return 'coros';
      case 'cala':
        return 'cala';
      case 'lluvias de bendición':
      case 'lluvias de bendicion':
        return 'lluvias';
      case 'poder del evangelio':
        return 'poder';
      default:
        return 'default';
    }
  }

  // Método sincrónico para obtener color (usa cache o fallback)
  static Color getColorForHimnarioSync(String nombreHimnario) {
    print('🔍 Buscando color para: $nombreHimnario');
    print('📊 Cache disponible: ${_coloresCache.keys}');

    if (_coloresCache.containsKey(nombreHimnario)) {
      final colorHex = _coloresCache[nombreHimnario]!['color'] as String?;
      print('✅ Encontrado en cache - Color: $colorHex');
      if (colorHex != null) {
        final color = Color(
          int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
        );
        print('🎨 Color calculado: $color');
        return color;
      }
    }

    print(
      '⚠️ No encontrado en cache, usando fallback para: ${_mapNombreToKey(nombreHimnario)}',
    );
    return AppTheme.getColorForHimnario(_mapNombreToKey(nombreHimnario));
  }

  // Método sincrónico para obtener gradiente (usa cache o fallback)
  static LinearGradient getGradientForHimnarioSync(String nombreHimnario) {
    print('🌈 Buscando gradiente para: $nombreHimnario');

    if (_coloresCache.containsKey(nombreHimnario)) {
      final colorHex = _coloresCache[nombreHimnario]!['color'] as String?;
      final colorDarkHex =
          _coloresCache[nombreHimnario]!['color_dark'] as String?;

      print('✅ Encontrado en cache - Color: $colorHex, Dark: $colorDarkHex');

      if (colorHex != null && colorDarkHex != null) {
        final colorPrimario = Color(
          int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
        );
        final colorSecundario = Color(
          int.parse(colorDarkHex.substring(1), radix: 16) + 0xFF000000,
        );

        print('🎨 Gradiente calculado: $colorPrimario -> $colorSecundario');
        return LinearGradient(
          colors: [colorPrimario, colorSecundario],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
    }

    print(
      '⚠️ No encontrado en cache, usando fallback para: ${_mapNombreToKey(nombreHimnario)}',
    );
    return AppTheme.getGradientForHimnario(_mapNombreToKey(nombreHimnario));
  }
}
