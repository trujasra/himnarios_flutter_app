class Himnario {
  final int id;
  final String nombre;
  final String color;
  final String colorSecundario;
  final String colorTexto;
  final int canciones;
  final String descripcion;
  final List<String> idiomas;

  const Himnario({
    required this.id,
    required this.nombre,
    required this.color,
    required this.colorSecundario,
    required this.colorTexto,
    required this.canciones,
    required this.descripcion,
    required this.idiomas,
  });

  factory Himnario.fromJson(Map<String, dynamic> json) {
    return Himnario(
      id: json['id'],
      nombre: json['nombre'],
      color: json['color'],
      colorSecundario: json['colorSecundario'],
      colorTexto: json['colorTexto'],
      canciones: json['canciones'],
      descripcion: json['descripcion'],
      idiomas: List<String>.from(json['idiomas']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'colorSecundario': colorSecundario,
      'colorTexto': colorTexto,
      'canciones': canciones,
      'descripcion': descripcion,
      'idiomas': idiomas,
    };
  }
} 