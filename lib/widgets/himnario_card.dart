import 'package:flutter/material.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';

class HimnarioCard extends StatelessWidget {
  final Himnario himnario;
  final VoidCallback onTap;

  const HimnarioCard({
    super.key,
    required this.himnario,
    required this.onTap,
  });

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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Barra de color superior
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: AppTheme.getGradientForHimnario(himnario.color),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              
              // Contenido de la tarjeta
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icono del himnario
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppTheme.getGradientForHimnario(himnario.color),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.book,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Información del himnario
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            himnario.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            himnario.descripcion,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              // Badge de número de canciones
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getColorForHimnario(himnario.color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _getColorForHimnario(himnario.color).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '${himnario.canciones} canciones',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _getColorForHimnario(himnario.color),
                                  ),
                                ),
                              ),
                              
                              // Badges de idiomas
                              ...himnario.idiomas.map((idioma) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.language,
                                      size: 10,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      idioma,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Icono de flecha
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForHimnario(String color) {
    switch (color) {
      case 'emerald':
        return AppTheme.emeraldColor;
      case 'violet':
        return AppTheme.violetColor;
      case 'amber':
        return AppTheme.amberColor;
      default:
        return AppTheme.primaryColor;
    }
  }


} 