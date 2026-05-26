class MarcaModel {
  final String id;
  final String nombre;
  final String paisOrigen;
  final String logoUrl;
  final String descripcion;
  final bool activo;

  MarcaModel({
    required this.id,
    required this.nombre,
    required this.paisOrigen,
    this.logoUrl = '',
    this.descripcion = '',
    this.activo = true,
  });

  factory MarcaModel.fromMap(Map<String, dynamic> map, String id) {
    return MarcaModel(
      id: id,
      nombre: map['nombre'] ?? '',
      paisOrigen: map['paisOrigen'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      descripcion: map['descripcion'] ?? '',
      activo: map['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'paisOrigen': paisOrigen,
      'logoUrl': logoUrl,
      'descripcion': descripcion,
      'activo': activo,
    };
  }

  MarcaModel copyWith({
    String? id,
    String? nombre,
    String? paisOrigen,
    String? logoUrl,
    String? descripcion,
    bool? activo,
  }) {
    return MarcaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      paisOrigen: paisOrigen ?? this.paisOrigen,
      logoUrl: logoUrl ?? this.logoUrl,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
    );
  }
}
