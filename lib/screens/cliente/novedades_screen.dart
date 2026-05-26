import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalogo_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/product_card.dart';
import 'producto_detalle_screen.dart';

class NovedadesScreen extends StatelessWidget {
  const NovedadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogoProvider>(
      builder: (context, catalogo, _) {
        final items = catalogo.novedades;

        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
                SizedBox(height: 8),
                Text('No hay novedades aún',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final p = items[index];
            return ProductCard(
              producto: p,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductoDetalleScreen(productoId: p.id),
                ),
              ),
              onAgregarCarrito: () {
                context.read<CarritoProvider>().agregarItem(p, null, 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${p.nombre} agregado al carrito'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
