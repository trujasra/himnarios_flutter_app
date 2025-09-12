class Lista {
  final int? id;
  final String nombre;
  final String descripcion;
  final bool estadoRegistro;
  final String fechaRegistro;
  final String usuarioRegistro;
  final String? fechaModificacion;
  final String? usuarioModificacion;

  Lista({
    this.id,
    required this.nombre,
    required this.descripcion,
    this.estadoRegistro = true,
    required this.fechaRegistro,
    required this.usuarioRegistro,
    this.fechaModificacion,
    this.usuarioModificacion,
  });

  factory Lista.fromJson(Map<String, dynamic> json) {
    return Lista(
      id: json['id_lista'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      estadoRegistro: json['estado_registro'] == 1,
      fechaRegistro: json['fecha_registro'],
      usuarioRegistro: json['usuario_registro'],
      fechaModificacion: json['fecha_modificacion'],
      usuarioModificacion: json['usuario_modificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id_lista': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'estado_registro': estadoRegistro ? 1 : 0,
      'fecha_registro': fechaRegistro,
      'usuario_registro': usuarioRegistro,
      'fecha_modificacion': fechaModificacion,
      'usuario_modificacion': usuarioModificacion,
    };
  }
}
