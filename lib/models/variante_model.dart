class VarianteModel {
  final String id;
  final String productoId;
  final String tono;
  final String codigoHex;
  final int stock;
  final String sku;

  VarianteModel({
    required this.id,
    required this.productoId,
    this.tono = '',
    this.codigoHex = '',
    this.stock = 0,
    this.sku = '',
  });

  factory VarianteModel.fromMap(Map<String, dynamic> map, String id) {
    return VarianteModel(
      id: id,
      productoId: map['productoId'] ?? '',
      tono: map['tono'] ?? '',
      codigoHex: map['codigoHex'] ?? '',
      stock: map['stock'] ?? 0,
      sku: map['sku'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'tono': tono,
      'codigoHex': codigoHex,
      'stock': stock,
      'sku': sku,
    };
  }

  VarianteModel copyWith({
    String? id,
    String? productoId,
    String? tono,
    String? codigoHex,
    int? stock,
    String? sku,
  }) {
    return VarianteModel(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      tono: tono ?? this.tono,
      codigoHex: codigoHex ?? this.codigoHex,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
    );
  }
}
