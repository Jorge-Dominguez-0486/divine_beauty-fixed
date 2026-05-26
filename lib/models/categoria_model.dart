class CategoriaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String iconoUrl;
  final String colorHex;

  CategoriaModel({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    this.iconoUrl = '',
    this.colorHex = '',
  });

  factory CategoriaModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoriaModel(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      iconoUrl: map['iconoUrl'] ?? '',
      colorHex: map['colorHex'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'iconoUrl': iconoUrl,
      'colorHex': colorHex,
    };
  }

  CategoriaModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? iconoUrl,
    String? colorHex,
  }) {
    return CategoriaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      iconoUrl: iconoUrl ?? this.iconoUrl,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
