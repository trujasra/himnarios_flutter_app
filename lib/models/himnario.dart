class Himnario {
  final int id;
  final String nombre;
  final String color;
  final String colorSecundario;
  final String colorTexto;
  final int canciones;
  final String descripcion;
  final List<String> idiomas;
  // Nuevos campos dinámicos
  final String? colorHex;
  final String? colorDarkHex;
  final String? imagenFondo;
  final int? inactividadMinutos;
  final int estadoRegistro; // 1: activo, 0: inactivo

  const Himnario({
    required this.id,
    required this.nombre,
    required this.color,
    required this.colorSecundario,
    required this.colorTexto,
    required this.canciones,
    required this.descripcion,
    required this.idiomas,
    this.colorHex,
    this.colorDarkHex,
    this.imagenFondo,
    this.inactividadMinutos,
    this.estadoRegistro = 1, // Por defecto activo
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
      colorHex: json['colorHex'],
      colorDarkHex: json['colorDarkHex'],
      imagenFondo: json['imagenFondo'],
      inactividadMinutos: json['inactividadMinutos'],
      estadoRegistro: json['estado_registro'] ?? 1,
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
      'colorHex': colorHex,
      'colorDarkHex': colorDarkHex,
      'imagenFondo': imagenFondo,
      'inactividadMinutos': inactividadMinutos,
      'estado_registro': estadoRegistro,
    };
  }

  // Método para crear una copia modificada del himnario
  Himnario copyWith({
    int? id,
    String? nombre,
    String? color,
    String? colorSecundario,
    String? colorTexto,
    int? canciones,
    String? descripcion,
    List<String>? idiomas,
    String? colorHex,
    String? colorDarkHex,
    String? imagenFondo,
    int? inactividadMinutos,
    int? estadoRegistro,
  }) {
    return Himnario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      colorSecundario: colorSecundario ?? this.colorSecundario,
      colorTexto: colorTexto ?? this.colorTexto,
      canciones: canciones ?? this.canciones,
      descripcion: descripcion ?? this.descripcion,
      idiomas: idiomas ?? List<String>.from(this.idiomas),
      colorHex: colorHex ?? this.colorHex,
      colorDarkHex: colorDarkHex ?? this.colorDarkHex,
      imagenFondo: imagenFondo ?? this.imagenFondo,
      inactividadMinutos: inactividadMinutos ?? this.inactividadMinutos,
      estadoRegistro: estadoRegistro ?? this.estadoRegistro,
    );
  }
}