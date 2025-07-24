import 'package:flutter/material.dart';
import '../data/canciones_data.dart';
import '../models/cancion.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';

class CancionScreen extends StatefulWidget {
  final Cancion cancion;
  final Himnario himnario;
  final List<int> favoritos;
  final Function(int) onToggleFavorito;

  const CancionScreen({
    super.key,
    required this.cancion,
    required this.himnario,
    required this.favoritos,
    required this.onToggleFavorito,
  });

  @override
  State<CancionScreen> createState() => _CancionScreenState();
}

class _CancionScreenState extends State<CancionScreen> {
  late String idiomaSeleccionado;

  @override
  void initState() {
    super.initState();
    idiomaSeleccionado = widget.cancion.idioma;
  }

  List<Cancion> get versionesCancion {
    return canciones.where((c) => 
      c.numero == widget.cancion.numero && 
      c.himnario == widget.cancion.himnario
    ).toList();
  }

  bool get tieneMultiplesIdiomas => versionesCancion.length > 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC), // Slate-50
              Colors.white,
              Color(0xFFF1F5F9), // Slate-100
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header de canción
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.getGradientForHimnario(widget.himnario.color),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Barra superior
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  widget.cancion.titulo,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (widget.cancion.tituloSecundario != null)
                                  Text(
                                    widget.cancion.tituloSecundario!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '#${widget.cancion.numero} - ${widget.cancion.himnario}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    if (tieneMultiplesIdiomas) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.language,
                                              size: 10,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Multiidioma',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => widget.onToggleFavorito(widget.cancion.id),
                            icon: Icon(
                              widget.favoritos.contains(widget.cancion.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Contenido de la canción
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: tieneMultiplesIdiomas
                      ? _buildMultiIdiomaView()
                      : _buildSingleIdiomaView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiIdiomaView() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Tabs de idiomas
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: versionesCancion.map((version) {
                final isSelected = version.idioma == idiomaSeleccionado;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => idiomaSeleccionado = version.idioma),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2)]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.language, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            version.idioma,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? AppTheme.textColor : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Contenido de la letra
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildLetraContent(versionesCancion.firstWhere((v) => v.idioma == idiomaSeleccionado)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleIdiomaView() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildLetraContent(widget.cancion),
      ),
    );
  }

  Widget _buildLetraContent(Cancion cancion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badges de información
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getColorForHimnario(widget.himnario.color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getColorForHimnario(widget.himnario.color).withOpacity(0.3),
                ),
              ),
              child: Text(
                cancion.categoria,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getColorForHimnario(widget.himnario.color),
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (cancion.idioma != "Español")
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language, size: 10, color: Colors.blue),
                    SizedBox(width: 3),
                    Text(
                      'Idioma',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Letra de la canción
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF9FAFB), Colors.white],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                cancion.letra,
                style: TextStyle(
                  fontSize: 20,
                  height: 2.0,
                  color: AppTheme.textColor,
                  fontFamily: cancion.idioma == "Aymara" ? 'serif' : null,
                ),
              ),
            ),
          ),
        ),
        
        // Información adicional para Aymara
        if (cancion.idioma == "Aymara") ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.language, color: Colors.blue, size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Idioma Aymara: Esta es la versión en lengua originaria aymara de la misma canción.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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