class OrdenCompraModel {
  final String id;
  final String proveedorId;
  final String fecha;
  final String estatus;
  final double total;
  final String notas;

  OrdenCompraModel({
    required this.id,
    required this.proveedorId,
    this.fecha = '',
    this.estatus = 'borrador',
    this.total = 0.0,
    this.notas = '',
  });

  factory OrdenCompraModel.fromMap(Map<String, dynamic> map, String id) {
    return OrdenCompraModel(
      id: id,
      proveedorId: map['proveedorId'] ?? '',
      fecha: map['fecha'] ?? '',
      estatus: map['estatus'] ?? 'borrador',
      total: (map['total'] ?? 0.0).toDouble(),
      notas: map['notas'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'proveedorId': proveedorId,
      'fecha': fecha,
      'estatus': estatus,
      'total': total,
      'notas': notas,
    };
  }

  OrdenCompraModel copyWith({
    String? id,
    String? proveedorId,
    String? fecha,
    String? estatus,
    double? total,
    String? notas,
  }) {
    return OrdenCompraModel(
      id: id ?? this.id,
      proveedorId: proveedorId ?? this.proveedorId,
      fecha: fecha ?? this.fecha,
      estatus: estatus ?? this.estatus,
      total: total ?? this.total,
      notas: notas ?? this.notas,
    );
  }
}
