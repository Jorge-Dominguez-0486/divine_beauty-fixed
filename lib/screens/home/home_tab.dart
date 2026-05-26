import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalogo_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/product_card.dart';
import '../cliente/producto_detalle_screen.dart';
import 'package:intl/intl.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _searchController = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogoProvider>(
      builder: (context, catalogo, _) {
        if (catalogo.cargando) {
          return const Center(child: CircularProgressIndicator());
        }

        final productosFiltrados = _busqueda.isEmpty
            ? catalogo.destacados
            : catalogo.productos
                .where((p) =>
                    p.nombre.toLowerCase().contains(_busqueda.toLowerCase()))
                .toList();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'Categorías',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _chipCategoria('Todas', null, catalogo),
                    ...catalogo.categorias.map(
                      (c) => _chipCategoria(c.nombre, c.id, catalogo),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Destacados',
                        style: Theme.of(context).textTheme.titleLarge),
                    if (catalogo.categoriaFiltro != null)
                      TextButton(
                        onPressed: () => catalogo.filtrarPorCategoria(null),
                        child: const Text('Ver todo'),
                      ),
                  ],
                ),
              ),
            ),
            if (productosFiltrados.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No hay productos disponibles',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = productosFiltrados[index];
                      return ProductCard(
                        producto: p,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductoDetalleScreen(productoId: p.id),
                          ),
                        ),
                        onAgregarCarrito: () {
                          Provider.of<CarritoProvider>(context, listen: false)
                              .agregarItem(p, null, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('\${p.nombre} agregado al carrito ✓'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                    childCount: productosFiltrados.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _chipCategoria(String label, String? id, CatalogoProvider catalogo) {
    final selected = catalogo.categoriaFiltro == id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.textPrimaryColor,
          fontSize: 13,
        ),
        onSelected: (_) => catalogo.filtrarPorCategoria(id),
      ),
    );
  }
}
