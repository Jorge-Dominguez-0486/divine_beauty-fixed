import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/carrito_provider.dart';
import '../../services/firestore_service.dart';
import '../../config/app_theme.dart';
import 'checkout_screen.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final _cuponController = TextEditingController();
  final _firestore = FirestoreService();

  static final _formato = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void dispose() {
    _cuponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CarritoProvider>(
      builder: (context, carrito, _) {
        if (carrito.estaVacio) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 64, color: Colors.grey),
                SizedBox(height: 8),
                Text('Tu carrito está vacío',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        final items = carrito.items;

        return Column(
          children: [
            // Badge de cantidad en AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text('${carrito.totalItems} artículo(s)',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Dismissible(
                    key: Key(item.keyId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => carrito.quitarItem(
                        item.producto.id, item.variante?.id),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.producto.imagenPrincipalUrl.isEmpty
                                  ? Container(
                                      width: 60,
                                      height: 60,
                                      color: AppTheme.surfaceColor,
                                      child: const Icon(
                                          Icons.face_retouching_natural,
                                          size: 30,
                                          color: AppTheme.primaryColor),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl:
                                          item.producto.imagenPrincipalUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                          color: AppTheme.surfaceColor),
                                      errorWidget: (_, __, ___) => Container(
                                        color: AppTheme.surfaceColor,
                                        child: const Icon(
                                            Icons.face_retouching_natural,
                                            size: 30,
                                            color: AppTheme.primaryColor),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.producto.nombre,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  if (item.variante != null)
                                    Text('Tono: ${item.variante!.tono}',
                                        style: const TextStyle(
                                            color: AppTheme
                                                .textSecondaryColor,
                                            fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(_formato.format(item.producto.precio),
                                      style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.remove_circle_outline,
                                      size: 20),
                                  onPressed: () => carrito.cambiarCantidad(
                                      item.producto.id,
                                      item.variante?.id,
                                      item.cantidad - 1),
                                ),
                                Text('${item.cantidad}',
                                    style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      size: 20),
                                  onPressed: () => carrito.cambiarCantidad(
                                      item.producto.id,
                                      item.variante?.id,
                                      item.cantidad + 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Cupón
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: carrito.cuponAplicado != null
                  ? Chip(
                      label: Text(
                          '${carrito.codigoCupon} - (${_formato.format(carrito.descuento)})'),
                      backgroundColor: Colors.green.shade100,
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => carrito.quitarCupon(),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cuponController,
                            decoration: InputDecoration(
                              hintText: 'Código de cupón',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              final ok = await carrito.aplicarCupon(
                                  _cuponController.text.trim(), _firestore);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? 'Cupón aplicado'
                                      : 'Cupón inválido o expirado'),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          child: const Text('Aplicar'),
                        ),
                      ],
                    ),
            ),
            // Resumen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  _resumenRow('Subtotal', _formato.format(carrito.subtotal)),
                  if (carrito.descuento > 0)
                    _resumenRow('Descuento',
                        '-${_formato.format(carrito.descuento)}',
                        color: Colors.green),
                  const Divider(),
                  _resumenRow('Total', _formato.format(carrito.total),
                      isTotal: true),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CheckoutScreen()),
                      ),
                      child: const Text('Proceder al Checkout',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _resumenRow(String label, String valor,
      {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              )),
          Text(valor,
              style: TextStyle(
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: color ?? AppTheme.textPrimaryColor,
              )),
        ],
      ),
    );
  }
}
