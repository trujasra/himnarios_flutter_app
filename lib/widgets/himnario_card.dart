import 'package:flutter/material.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';

class HimnarioCard extends StatelessWidget {
  final Himnario himnario;
  final VoidCallback onTap;

  const HimnarioCard({super.key, required this.himnario, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: _getGradientForHimnario(himnario.nombre),
            ),
            child: Column(
              children: [
                // Header con imagen de fondo y overlay
                Container(
                  height: 140, // Aumentado para acomodar títulos más largos
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getColorForHimnario(himnario.nombre).withValues(alpha: 0.8),
                        _getColorForHimnario(himnario.nombre).withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Patrón de fondo decorativo
                      Positioned.fill(
                        child: CustomPaint(
                          painter: MenuPatternPainter(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      // Contenido del header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Icono del himnario
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _getIconForHimnario(himnario.nombre),
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Información del himnario
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    himnario.nombre,
                                    style: const TextStyle(
                                      fontFamily: 'Berkshire Swash',
                                      fontSize:
                                          20, // Reducido para títulos largos
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow
                                        .visible, // Mostrar texto completo
                                    maxLines: 2, // Permitir hasta 2 líneas
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    himnario.descripcion,
                                    style: TextStyle(
                                      fontSize: 12, // Reducido ligeramente
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            // Badge con cantidad de canciones
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${himnario.canciones}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Footer con idiomas y botón
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      // Idiomas disponibles
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.language,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Idiomas:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ..._getIdiomasChips(),
                          ],
                        ),
                      ),
                      // Botón de acción
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: _getGradientForHimnario(himnario.nombre),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _getColorForHimnario(
                                himnario.nombre,
                              ).withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Ver',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForHimnario(String nombre) {
    if (nombre.toLowerCase().contains('bendición del cielo')) {
      return Icons.favorite;
    } else if (nombre.toLowerCase().contains('coros cristianos')) {
      return Icons.music_note;
    } else if (nombre.toLowerCase().contains('cala')) {
      return Icons.water_drop;
    } else if (nombre.toLowerCase().contains('especial')) {
      return Icons.star;
    } else {
      return Icons.book;
    }
  }

  // Método para obtener el gradiente específico según el nombre del himnario
  LinearGradient _getGradientForHimnario(String nombre) {
    if (nombre.toLowerCase().contains('bendición del cielo')) {
      return const LinearGradient(
        colors: [AppTheme.bendicionColor, AppTheme.bendicionDarkColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (nombre.toLowerCase().contains('coros cristianos')) {
      return const LinearGradient(
        colors: [AppTheme.corosColor, AppTheme.corosDarkColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (nombre.toLowerCase().contains('cala')) {
      return const LinearGradient(
        colors: [AppTheme.calaColor, AppTheme.calaDarkColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (nombre.toLowerCase().contains('poder del')) {
      return const LinearGradient(
        colors: [AppTheme.poderColor, AppTheme.poderDarkColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (nombre.toLowerCase().contains('lluvias de')) {
      return const LinearGradient(
        colors: [AppTheme.lluviasColor, AppTheme.lluviasDarkColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return AppTheme.getGradientForHimnario(himnario.color);
    }
  }

  // Método para obtener el color específico según el nombre del himnario
  Color _getColorForHimnario(String nombre) {
    if (nombre.toLowerCase().contains('bendición del cielo')) {
      return AppTheme.bendicionColor;
    } else if (nombre.toLowerCase().contains('coros cristianos')) {
      return AppTheme.corosColor;
    } else if (nombre.toLowerCase().contains('cala')) {
      return AppTheme.calaColor;
    } else if (nombre.toLowerCase().contains('poder del')) {
      return AppTheme.poderColor;
    } else if (nombre.toLowerCase().contains('lluvias de')) {
      return AppTheme.lluviasColor;
    } else {
      return AppTheme.getColorForHimnario(himnario.color);
    }
  }

  List<Widget> _getIdiomasChips() {
    // Obtener idiomas únicos del himnario
    final idiomas = himnario.idiomas.toSet();

    return idiomas.take(3).map((idioma) {
      return Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getColorForIdioma(idioma).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getColorForIdioma(idioma).withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          idioma,
          style: TextStyle(
            fontSize: 10,
            color: _getColorForIdioma(idioma),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }).toList();
  }

  Color _getColorForIdioma(String idioma) {
    switch (idioma.toLowerCase()) {
      case 'aymara':
        return const Color.fromARGB(255, 187, 113, 1);
      case 'español':
        return const Color.fromARGB(255, 0, 156, 135); // Rojo elegante para Español
      case 'quechua':
        return const Color(0xFF4A90E2); // Azul elegante para Aymara
      default:
        return Colors.grey; // Color por defecto
    }
  }
}

// Pintor personalizado para el patrón de fondo
class MenuPatternPainter extends CustomPainter {
  final Color color;

  MenuPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Dibujar líneas diagonales
    for (int i = 0; i < size.width + size.height; i += 20) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(0, i.toDouble()), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
