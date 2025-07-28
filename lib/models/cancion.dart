class Cancion {
  final int id;
  final String titulo;
  final String? tituloSecundario;
  final int numero;
  final String himnario;
  final String idioma;
  final String categoria;
  final String letra;
  final List<Cancion>? versiones; // Para canciones con múltiples idiomas

  const Cancion({
    required this.id,
    required this.titulo,
    this.tituloSecundario,
    required this.numero,
    required this.himnario,
    required this.idioma,
    required this.categoria,
    required this.letra,
    this.versiones,
  });

  factory Cancion.fromJson(Map<String, dynamic> json) {
    return Cancion(
      id: json['id'],
      titulo: json['titulo'],
      tituloSecundario: json['tituloSecundario'],
      numero: json['numero'],
      himnario: json['himnario'],
      idioma: json['idioma'],
      categoria: json['categoria'],
      letra: json['letra'],
      versiones: json['versiones'] != null 
          ? (json['versiones'] as List).map((v) => Cancion.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'tituloSecundario': tituloSecundario,
      'numero': numero,
      'himnario': himnario,
      'idioma': idioma,
      'categoria': categoria,
      'letra': letra,
      'versiones': versiones?.map((v) => v.toJson()).toList(),
    };
  }

  // Helper para verificar si la canción tiene múltiples versiones
  bool get tieneMultiplesVersiones => versiones != null && versiones!.length > 1;
  
  // Helper para obtener la versión en un idioma específico
  Cancion? getVersionEnIdioma(String idioma) {
    if (versiones == null) return null;
    try {
      return versiones!.firstWhere((c) => c.idioma == idioma);
    } catch (e) {
      return null;
    }
  }
} 