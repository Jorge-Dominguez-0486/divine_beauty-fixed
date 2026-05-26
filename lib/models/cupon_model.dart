class CuponModel {
  final String id;
  final String codigo;
  final String tipoDescuento;
  final double valor;
  final String vigencia;
  final bool activo;
  final int usoMaximo;
  final int usoActual;

  CuponModel({
    required this.id,
    required this.codigo,
    this.tipoDescuento = 'porcentaje',
    this.valor = 0.0,
    this.vigencia = '',
    this.activo = true,
    this.usoMaximo = 0,
    this.usoActual = 0,
  });

  factory CuponModel.fromMap(Map<String, dynamic> map, String id) {
    return CuponModel(
      id: id,
      codigo: map['codigo'] ?? '',
      tipoDescuento: map['tipoDescuento'] ?? 'porcentaje',
      valor: (map['valor'] ?? 0.0).toDouble(),
      vigencia: map['vigencia'] ?? '',
      activo: map['activo'] ?? true,
      usoMaximo: map['usoMaximo'] ?? 0,
      usoActual: map['usoActual'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'tipoDescuento': tipoDescuento,
      'valor': valor,
      'vigencia': vigencia,
      'activo': activo,
      'usoMaximo': usoMaximo,
      'usoActual': usoActual,
    };
  }

  CuponModel copyWith({
    String? id,
    String? codigo,
    String? tipoDescuento,
    double? valor,
    String? vigencia,
    bool? activo,
    int? usoMaximo,
    int? usoActual,
  }) {
    return CuponModel(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      tipoDescuento: tipoDescuento ?? this.tipoDescuento,
      valor: valor ?? this.valor,
      vigencia: vigencia ?? this.vigencia,
      activo: activo ?? this.activo,
      usoMaximo: usoMaximo ?? this.usoMaximo,
      usoActual: usoActual ?? this.usoActual,
    );
  }
}
