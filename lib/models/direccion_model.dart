class DireccionModel {
  final String id;
  final String clienteId;
  final String calle;
  final String colonia;
  final String ciudad;
  final String estado;
  final String codigoPostal;
  final bool esPrincipal;

  DireccionModel({
    required this.id,
    required this.clienteId,
    this.calle = '',
    this.colonia = '',
    this.ciudad = '',
    this.estado = '',
    this.codigoPostal = '',
    this.esPrincipal = false,
  });

  factory DireccionModel.fromMap(Map<String, dynamic> map, String id) {
    return DireccionModel(
      id: id,
      clienteId: map['clienteId'] ?? '',
      calle: map['calle'] ?? '',
      colonia: map['colonia'] ?? '',
      ciudad: map['ciudad'] ?? '',
      estado: map['estado'] ?? '',
      codigoPostal: map['codigoPostal'] ?? '',
      esPrincipal: map['esPrincipal'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'calle': calle,
      'colonia': colonia,
      'ciudad': ciudad,
      'estado': estado,
      'codigoPostal': codigoPostal,
      'esPrincipal': esPrincipal,
    };
  }

  DireccionModel copyWith({
    String? id,
    String? clienteId,
    String? calle,
    String? colonia,
    String? ciudad,
    String? estado,
    String? codigoPostal,
    bool? esPrincipal,
  }) {
    return DireccionModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      calle: calle ?? this.calle,
      colonia: colonia ?? this.colonia,
      ciudad: ciudad ?? this.ciudad,
      estado: estado ?? this.estado,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      esPrincipal: esPrincipal ?? this.esPrincipal,
    );
  }
}
