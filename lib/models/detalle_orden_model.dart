class DetalleOrdenModel {
  final String id;
  final String ordenCompraId;
  final String varianteId;
  final String productoNombre;
  final int cantidad;
  final double precioCosto;

  DetalleOrdenModel({
    required this.id,
    required this.ordenCompraId,
    this.varianteId = '',
    this.productoNombre = '',
    this.cantidad = 1,
    this.precioCosto = 0.0,
  });

  factory DetalleOrdenModel.fromMap(Map<String, dynamic> map, String id) {
    return DetalleOrdenModel(
      id: id,
      ordenCompraId: map['ordenCompraId'] ?? '',
      varianteId: map['varianteId'] ?? '',
      productoNombre: map['productoNombre'] ?? '',
      cantidad: map['cantidad'] ?? 1,
      precioCosto: (map['precioCosto'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ordenCompraId': ordenCompraId,
      'varianteId': varianteId,
      'productoNombre': productoNombre,
      'cantidad': cantidad,
      'precioCosto': precioCosto,
    };
  }

  DetalleOrdenModel copyWith({
    String? id,
    String? ordenCompraId,
    String? varianteId,
    String? productoNombre,
    int? cantidad,
    double? precioCosto,
  }) {
    return DetalleOrdenModel(
      id: id ?? this.id,
      ordenCompraId: ordenCompraId ?? this.ordenCompraId,
      varianteId: varianteId ?? this.varianteId,
      productoNombre: productoNombre ?? this.productoNombre,
      cantidad: cantidad ?? this.cantidad,
      precioCosto: precioCosto ?? this.precioCosto,
    );
  }
}
