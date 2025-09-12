class ListaCancion {
  final int? id;
  final int idLista;
  final int idCancion;
  final bool estadoRegistro;
  final String fechaRegistro;
  final String usuarioRegistro;
  final String? fechaModificacion;
  final String? usuarioModificacion;

  ListaCancion({
    this.id,
    required this.idLista,
    required this.idCancion,
    this.estadoRegistro = true,
    required this.fechaRegistro,
    required this.usuarioRegistro,
    this.fechaModificacion,
    this.usuarioModificacion,
  });

  factory ListaCancion.fromJson(Map<String, dynamic> json) {
    return ListaCancion(
      id: json['id_lista_cancion'],
      idLista: json['id_lista'],
      idCancion: json['id_cancion'],
      estadoRegistro: json['estado_registro'] == 1,
      fechaRegistro: json['fecha_registro'],
      usuarioRegistro: json['usuario_registro'],
      fechaModificacion: json['fecha_modificacion'],
      usuarioModificacion: json['usuario_modificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id_lista_cancion': id,
      'id_lista': idLista,
      'id_cancion': idCancion,
      'estado_registro': estadoRegistro ? 1 : 0,
      'fecha_registro': fechaRegistro,
      'usuario_registro': usuarioRegistro,
      'fecha_modificacion': fechaModificacion,
      'usuario_modificacion': usuarioModificacion,
    };
  }
}
