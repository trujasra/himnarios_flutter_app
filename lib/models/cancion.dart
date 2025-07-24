class Cancion {
  final int id;
  final String titulo;
  final String? tituloSecundario;
  final int numero;
  final String himnario;
  final String idioma;
  final String categoria;
  final String letra;

  const Cancion({
    required this.id,
    required this.titulo,
    this.tituloSecundario,
    required this.numero,
    required this.himnario,
    required this.idioma,
    required this.categoria,
    required this.letra,
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
    };
  }
} 