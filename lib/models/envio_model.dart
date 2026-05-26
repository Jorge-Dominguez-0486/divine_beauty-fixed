class EnvioModel {
  final String id;
  final String pedidoId;
  final String numGuia;
  final String paqueteria;
  final String fechaEstimada;
  final String estatus;
  final String direccionDestino;

  EnvioModel({
    required this.id,
    required this.pedidoId,
    this.numGuia = '',
    this.paqueteria = '',
    this.fechaEstimada = '',
    this.estatus = '',
    this.direccionDestino = '',
  });

  factory EnvioModel.fromMap(Map<String, dynamic> map, String id) {
    return EnvioModel(
      id: id,
      pedidoId: map['pedidoId'] ?? '',
      numGuia: map['numGuia'] ?? '',
      paqueteria: map['paqueteria'] ?? '',
      fechaEstimada: map['fechaEstimada'] ?? '',
      estatus: map['estatus'] ?? '',
      direccionDestino: map['direccionDestino'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pedidoId': pedidoId,
      'numGuia': numGuia,
      'paqueteria': paqueteria,
      'fechaEstimada': fechaEstimada,
      'estatus': estatus,
      'direccionDestino': direccionDestino,
    };
  }

  EnvioModel copyWith({
    String? id,
    String? pedidoId,
    String? numGuia,
    String? paqueteria,
    String? fechaEstimada,
    String? estatus,
    String? direccionDestino,
  }) {
    return EnvioModel(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      numGuia: numGuia ?? this.numGuia,
      paqueteria: paqueteria ?? this.paqueteria,
      fechaEstimada: fechaEstimada ?? this.fechaEstimada,
      estatus: estatus ?? this.estatus,
      direccionDestino: direccionDestino ?? this.direccionDestino,
    );
  }
}
