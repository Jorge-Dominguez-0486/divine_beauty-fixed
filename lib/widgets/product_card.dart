import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../models/producto_model.dart';
import '../config/app_theme.dart';

class ProductCard extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback? onAgregarCarrito;
  final VoidCallback? onTap;
  final VoidCallback? onFavorito;
  final bool esFavorito;

  const ProductCard({
    super.key,
    required this.producto,
    this.onAgregarCarrito,
    this.onTap,
    this.onFavorito,
    this.esFavorito = false,
  });

  static final _formato = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildImage(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formato.format(producto.precio),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (onAgregarCarrito != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                  onPressed: onAgregarCarrito,
                ),
              ),
          ],
        ),
            if (onFavorito != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onFavorito,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      esFavorito ? Icons.favorite : Icons.favorite_border,
                      color: esFavorito ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (producto.imagenPrincipalUrl.isEmpty) {
      return Container(
        color: AppTheme.surfaceColor,
        child: const Center(
          child: Icon(Icons.face_retouching_natural,
              size: 40, color: AppTheme.primaryColor),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: producto.imagenPrincipalUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white),
        ),
        errorWidget: (_, __, ___) => Container(
          color: AppTheme.surfaceColor,
          child: const Icon(Icons.face_retouching_natural,
              size: 40, color: AppTheme.primaryColor),
        ),
      ),
    );
  }
}
