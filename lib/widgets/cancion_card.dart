import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';

class CancionCard extends StatelessWidget {
  final Cancion cancion;
  final Himnario himnario;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorito;
  final bool mostrarHimnario;

  const CancionCard({
    super.key,
    required this.cancion,
    required this.himnario,
    required this.isFavorite,
    required this.onTap,
    this.onToggleFavorito,
    this.mostrarHimnario = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                // Número de la canción
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.getGradientForHimnario(himnario.color),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cancion.numero.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Información de la canción
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                             Text(
                         cancion.titulo,
                         style: const TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w600,
                           color: Color.fromARGB(255, 30, 45, 59),
                         ),
                       ),
                       if (mostrarHimnario) ...[
                         const SizedBox(height: 2),
                         Text(
                           himnario.nombre,
                           style: TextStyle(
                             fontSize: 12,
                             color: Colors.grey,
                             fontWeight: FontWeight.w500,
                             fontStyle: FontStyle.italic,
                           ),
                         ),
                       ],
                      if (cancion.tituloSecundario != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          cancion.tituloSecundario!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Badge de idioma
                          if (cancion.tieneMultiplesVersiones)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.language,
                                    size: 10,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Multiidioma',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getColorForIdioma(cancion.idioma).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getColorForIdioma(cancion.idioma).withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.language,
                                    size: 10,
                                    color: _getColorForIdioma(cancion.idioma),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    cancion.idioma,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _getColorForIdioma(cancion.idioma),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                                 // Iconos de acción
                 Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     GestureDetector(
                       onTap: onToggleFavorito,
                       child: Icon(
                         isFavorite ? Icons.favorite : Icons.favorite_border,
                         color: isFavorite ? Colors.red : Colors.grey,
                         size: 20,
                       ),
                     ),
                     const SizedBox(width: 8),
                     const Icon(
                       Icons.chevron_right,
                       color: Colors.grey,
                       size: 20,
                     ),
                   ],
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para obtener el color según el idioma
  Color _getColorForIdioma(String idioma) {
    switch (idioma.toLowerCase()) {
      case 'aymara':
       return const Color(0xFF27AE60);      
      case 'español':
        return const Color.fromARGB(255, 177, 60, 231); // Rojo elegante para Español
      case 'quechua':

        return const Color(0xFF4A90E2); // Azul elegante para Aymara
      default:
        return Colors.grey; // Color por defecto
    }
  }
} 