class Usuario {
  final String nombre;
  final int estadoRegistro;

  Usuario({
    required this.nombre,
    required this.estadoRegistro,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      nombre: map['nombre'] as String,
      estadoRegistro: map['estado_registro'] as int,
    );
  }
}
