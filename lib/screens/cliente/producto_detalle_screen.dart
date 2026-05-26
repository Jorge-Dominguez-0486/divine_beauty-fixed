import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/catalogo_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../models/variante_model.dart';
import '../../services/firestore_service.dart';
import '../../config/app_theme.dart';

class ProductoDetalleScreen extends StatefulWidget {
  final String productoId;

  const ProductoDetalleScreen({super.key, required this.productoId});

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  final FirestoreService _firestore = FirestoreService();
  List<VarianteModel> _variantes = [];
  VarianteModel? _varianteSeleccionada;
  int _cantidad = 1;

  static final _formato = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _cargarVariantes();
  }

  void _cargarVariantes() async {
    try {
      final v = await _firestore.obtenerVariantesProducto(widget.productoId);
      if (mounted) setState(() => _variantes = v);
    } catch (_) {}
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse('0xFF${hex.replaceAll('#', '')}'));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogoProvider>(
      builder: (context, catalogo, _) {
        final producto = catalogo.obtenerProductoPorId(widget.productoId);
        if (producto == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Producto')),
            body: const Center(child: Text('Producto no encontrado')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(producto.nombre)),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (producto.imagenPrincipalUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: producto.imagenPrincipalUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppTheme.surfaceColor,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 300,
                      color: AppTheme.surfaceColor,
                      child: const Icon(Icons.face_retouching_natural,
                          size: 64, color: AppTheme.primaryColor),
                    ),
                  )
                else
                  Container(
                    height: 300,
                    color: AppTheme.surfaceColor,
                    child: const Center(
                      child: Icon(Icons.face_retouching_natural,
                          size: 64, color: AppTheme.primaryColor),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(producto.nombre,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(_formato.format(producto.precio),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          )),
                      const SizedBox(height: 16),
                      Text(producto.descripcion,
                          style: Theme.of(context).textTheme.bodyLarge),
                      if (producto.marcaId.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Marca: ${producto.marcaId}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                      if (_variantes.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text('Tono / Variante',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _variantes.map((v) {
                            final selected =
                                _varianteSeleccionada?.id == v.id;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _varianteSeleccionada = v),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: v.codigoHex.isNotEmpty
                                      ? _hexToColor(v.codigoHex)
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: selected
                                        ? AppTheme.primaryColor
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: selected
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 20)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                        Text(
                          _varianteSeleccionada != null
                              ? _varianteSeleccionada!.tono
                              : 'Selecciona un tono',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (producto.stock > 0) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text('Cantidad:'),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: _cantidad > 1
                                  ? () => setState(() => _cantidad--)
                                  : null,
                            ),
                            Text('$_cantidad',
                                style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: _cantidad < producto.stock
                                  ? () => setState(() => _cantidad++)
                                  : null,
                            ),
                            Text('${producto.stock} disponibles',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _variantes.isNotEmpty &&
                                  _varianteSeleccionada == null
                              ? null
                              : () {
                                  // ✅ CORRECCIÓN: ahora sí agrega al CarritoProvider
                                  Provider.of<CarritoProvider>(context,
                                          listen: false)
                                      .agregarItem(
                                    producto,
                                    _varianteSeleccionada,
                                    _cantidad,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${producto.nombre} agregado al carrito'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Agregar al carrito'),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text('Reseñas',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            return Icon(
                              i < producto.rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text('${producto.rating.toStringAsFixed(1)} / 5'),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
