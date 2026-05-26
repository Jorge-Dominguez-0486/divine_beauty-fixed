class ProveedorModel {
  final String id;
  final String nombre;
  final String contacto;
  final String email;
  final String telefono;
  final String pais;
  final bool activo;

  ProveedorModel({
    required this.id,
    required this.nombre,
    this.contacto = '',
    this.email = '',
    this.telefono = '',
    this.pais = '',
    this.activo = true,
  });

  factory ProveedorModel.fromMap(Map<String, dynamic> map, String id) {
    return ProveedorModel(
      id: id,
      nombre: map['nombre'] ?? '',
      contacto: map['contacto'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      pais: map['pais'] ?? '',
      activo: map['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'contacto': contacto,
      'email': email,
      'telefono': telefono,
      'pais': pais,
      'activo': activo,
    };
  }

  ProveedorModel copyWith({
    String? id,
    String? nombre,
    String? contacto,
    String? email,
    String? telefono,
    String? pais,
    bool? activo,
  }) {
    return ProveedorModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      contacto: contacto ?? this.contacto,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      pais: pais ?? this.pais,
      activo: activo ?? this.activo,
    );
  }
}
