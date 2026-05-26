class PagoModel {
  final String id;
  final String pedidoId;
  final String metodo;
  final double monto;
  final String estatus;
  final String fecha;
  final String referencia;

  PagoModel({
    required this.id,
    required this.pedidoId,
    this.metodo = '',
    this.monto = 0.0,
    this.estatus = 'pendiente',
    this.fecha = '',
    this.referencia = '',
  });

  factory PagoModel.fromMap(Map<String, dynamic> map, String id) {
    return PagoModel(
      id: id,
      pedidoId: map['pedidoId'] ?? '',
      metodo: map['metodo'] ?? '',
      monto: (map['monto'] ?? 0.0).toDouble(),
      estatus: map['estatus'] ?? 'pendiente',
      fecha: map['fecha'] ?? '',
      referencia: map['referencia'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pedidoId': pedidoId,
      'metodo': metodo,
      'monto': monto,
      'estatus': estatus,
      'fecha': fecha,
      'referencia': referencia,
    };
  }

  PagoModel copyWith({
    String? id,
    String? pedidoId,
    String? metodo,
    double? monto,
    String? estatus,
    String? fecha,
    String? referencia,
  }) {
    return PagoModel(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      metodo: metodo ?? this.metodo,
      monto: monto ?? this.monto,
      estatus: estatus ?? this.estatus,
      fecha: fecha ?? this.fecha,
      referencia: referencia ?? this.referencia,
    );
  }
}
