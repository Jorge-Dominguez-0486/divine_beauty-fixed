class ClienteModel {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String fechaNacimiento;
  final String avatarUrl;
  final List<String> favoritos;
  final bool esAdmin;

  ClienteModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono = '',
    this.fechaNacimiento = '',
    this.avatarUrl = '',
    this.favoritos = const [],
    this.esAdmin = false,
  });

  factory ClienteModel.fromMap(Map<String, dynamic> map, String id) {
    return ClienteModel(
      id: id,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      fechaNacimiento: map['fechaNacimiento'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      favoritos: List<String>.from(map['favoritos'] ?? []),
      esAdmin: map['esAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'fechaNacimiento': fechaNacimiento,
      'avatarUrl': avatarUrl,
      'favoritos': favoritos,
      'esAdmin': esAdmin,
    };
  }

  ClienteModel copyWith({
    String? id,
    String? nombre,
    String? email,
    String? telefono,
    String? fechaNacimiento,
    String? avatarUrl,
    List<String>? favoritos,
    bool? esAdmin,
  }) {
    return ClienteModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favoritos: favoritos ?? this.favoritos,
      esAdmin: esAdmin ?? this.esAdmin,
    );
  }
}
