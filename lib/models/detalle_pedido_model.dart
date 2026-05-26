class DetallePedidoModel {
  final String id;
  final String pedidoId;
  final String varianteId;
  final String productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;

  DetallePedidoModel({
    required this.id,
    required this.pedidoId,
    this.varianteId = '',
    required this.productoId,
    this.nombreProducto = '',
    this.cantidad = 1,
    this.precioUnitario = 0.0,
  });

  factory DetallePedidoModel.fromMap(Map<String, dynamic> map, String id) {
    return DetallePedidoModel(
      id: id,
      pedidoId: map['pedidoId'] ?? '',
      varianteId: map['varianteId'] ?? '',
      productoId: map['productoId'] ?? '',
      nombreProducto: map['nombreProducto'] ?? '',
      cantidad: map['cantidad'] ?? 1,
      precioUnitario: (map['precioUnitario'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pedidoId': pedidoId,
      'varianteId': varianteId,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
    };
  }

  DetallePedidoModel copyWith({
    String? id,
    String? pedidoId,
    String? varianteId,
    String? productoId,
    String? nombreProducto,
    int? cantidad,
    double? precioUnitario,
  }) {
    return DetallePedidoModel(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      varianteId: varianteId ?? this.varianteId,
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
    );
  }
}
