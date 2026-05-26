class ProductoModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String categoriaId;
  final String marcaId;
  final double rating;
  final String imagenPrincipalUrl;
  final List<String> galeriaImagenes;
  final bool activo;

  ProductoModel({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    required this.precio,
    this.stock = 0,
    this.categoriaId = '',
    this.marcaId = '',
    this.rating = 0.0,
    this.imagenPrincipalUrl = '',
    this.galeriaImagenes = const [],
    this.activo = true,
  });

  factory ProductoModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductoModel(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0.0).toDouble(),
      stock: map['stock'] ?? 0,
      categoriaId: map['categoriaId'] ?? '',
      marcaId: map['marcaId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      imagenPrincipalUrl: map['imagenPrincipalUrl'] ?? '',
      galeriaImagenes: List<String>.from(map['galeriaImagenes'] ?? []),
      activo: map['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'categoriaId': categoriaId,
      'marcaId': marcaId,
      'rating': rating,
      'imagenPrincipalUrl': imagenPrincipalUrl,
      'galeriaImagenes': galeriaImagenes,
      'activo': activo,
    };
  }

  ProductoModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precio,
    int? stock,
    String? categoriaId,
    String? marcaId,
    double? rating,
    String? imagenPrincipalUrl,
    List<String>? galeriaImagenes,
    bool? activo,
  }) {
    return ProductoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      categoriaId: categoriaId ?? this.categoriaId,
      marcaId: marcaId ?? this.marcaId,
      rating: rating ?? this.rating,
      imagenPrincipalUrl: imagenPrincipalUrl ?? this.imagenPrincipalUrl,
      galeriaImagenes: galeriaImagenes ?? this.galeriaImagenes,
      activo: activo ?? this.activo,
    );
  }
}
