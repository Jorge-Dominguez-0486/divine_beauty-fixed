class PedidoModel {
  final String id;
  final String clienteId;
  final String fecha;
  final String estatus;
  final double subtotal;
  final double descuento;
  final double total;
  final String metodoPago;
  final String direccionId;

  PedidoModel({
    required this.id,
    required this.clienteId,
    required this.fecha,
    this.estatus = 'pendiente',
    this.subtotal = 0.0,
    this.descuento = 0.0,
    this.total = 0.0,
    this.metodoPago = '',
    this.direccionId = '',
  });

  factory PedidoModel.fromMap(Map<String, dynamic> map, String id) {
    return PedidoModel(
      id: id,
      clienteId: map['clienteId'] ?? '',
      fecha: map['fecha'] ?? '',
      estatus: map['estatus'] ?? 'pendiente',
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      descuento: (map['descuento'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      metodoPago: map['metodoPago'] ?? '',
      direccionId: map['direccionId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'fecha': fecha,
      'estatus': estatus,
      'subtotal': subtotal,
      'descuento': descuento,
      'total': total,
      'metodoPago': metodoPago,
      'direccionId': direccionId,
    };
  }

  PedidoModel copyWith({
    String? id,
    String? clienteId,
    String? fecha,
    String? estatus,
    double? subtotal,
    double? descuento,
    double? total,
    String? metodoPago,
    String? direccionId,
  }) {
    return PedidoModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      fecha: fecha ?? this.fecha,
      estatus: estatus ?? this.estatus,
      subtotal: subtotal ?? this.subtotal,
      descuento: descuento ?? this.descuento,
      total: total ?? this.total,
      metodoPago: metodoPago ?? this.metodoPago,
      direccionId: direccionId ?? this.direccionId,
    );
  }
}
