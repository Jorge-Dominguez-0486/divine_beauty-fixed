class FacturaModel {
  final String id;
  final String pedidoId;
  final String rfc;
  final String razonSocial;
  final String direccionFiscal;
  final String usoCFDI;
  final String fecha;

  FacturaModel({
    required this.id,
    required this.pedidoId,
    this.rfc = '',
    this.razonSocial = '',
    this.direccionFiscal = '',
    this.usoCFDI = '',
    this.fecha = '',
  });

  factory FacturaModel.fromMap(Map<String, dynamic> map, String id) {
    return FacturaModel(
      id: id,
      pedidoId: map['pedidoId'] ?? '',
      rfc: map['rfc'] ?? '',
      razonSocial: map['razonSocial'] ?? '',
      direccionFiscal: map['direccionFiscal'] ?? '',
      usoCFDI: map['usoCFDI'] ?? '',
      fecha: map['fecha'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pedidoId': pedidoId,
      'rfc': rfc,
      'razonSocial': razonSocial,
      'direccionFiscal': direccionFiscal,
      'usoCFDI': usoCFDI,
      'fecha': fecha,
    };
  }

  FacturaModel copyWith({
    String? id,
    String? pedidoId,
    String? rfc,
    String? razonSocial,
    String? direccionFiscal,
    String? usoCFDI,
    String? fecha,
  }) {
    return FacturaModel(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      rfc: rfc ?? this.rfc,
      razonSocial: razonSocial ?? this.razonSocial,
      direccionFiscal: direccionFiscal ?? this.direccionFiscal,
      usoCFDI: usoCFDI ?? this.usoCFDI,
      fecha: fecha ?? this.fecha,
    );
  }
}
