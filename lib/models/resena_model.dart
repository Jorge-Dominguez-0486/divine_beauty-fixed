class ResenaModel {
  final String id;
  final String clienteId;
  final String productoId;
  final int calificacion;
  final String comentario;
  final String fecha;
  final String nombreCliente;

  ResenaModel({
    required this.id,
    required this.clienteId,
    required this.productoId,
    this.calificacion = 5,
    this.comentario = '',
    this.fecha = '',
    this.nombreCliente = '',
  });

  factory ResenaModel.fromMap(Map<String, dynamic> map, String id) {
    return ResenaModel(
      id: id,
      clienteId: map['clienteId'] ?? '',
      productoId: map['productoId'] ?? '',
      calificacion: map['calificacion'] ?? 5,
      comentario: map['comentario'] ?? '',
      fecha: map['fecha'] ?? '',
      nombreCliente: map['nombreCliente'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'productoId': productoId,
      'calificacion': calificacion,
      'comentario': comentario,
      'fecha': fecha,
      'nombreCliente': nombreCliente,
    };
  }

  ResenaModel copyWith({
    String? id,
    String? clienteId,
    String? productoId,
    int? calificacion,
    String? comentario,
    String? fecha,
    String? nombreCliente,
  }) {
    return ResenaModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      productoId: productoId ?? this.productoId,
      calificacion: calificacion ?? this.calificacion,
      comentario: comentario ?? this.comentario,
      fecha: fecha ?? this.fecha,
      nombreCliente: nombreCliente ?? this.nombreCliente,
    );
  }
}
