import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalogo_provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/product_card.dart';
import 'producto_detalle_screen.dart';

class CategoriaScreen extends StatefulWidget {
  final String categoriaId;

  const CategoriaScreen({super.key, required this.categoriaId});

  @override
  State<CategoriaScreen> createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {
  String _sortBy = 'nombre';
  bool _asc = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogoProvider>(
      builder: (context, catalogo, _) {
        final cat = catalogo.obtenerCategoriaPorId(widget.categoriaId);
        var productos = catalogo.productos
            .where((p) => p.categoriaId == widget.categoriaId)
            .toList();

        if (_sortBy == 'precio') {
          productos.sort((a, b) =>
              _asc ? a.precio.compareTo(b.precio) : b.precio.compareTo(a.precio));
        } else {
          productos.sort((a, b) =>
              _asc
                  ? a.nombre.compareTo(b.nombre)
                  : b.nombre.compareTo(a.nombre));
        }

        return Scaffold(
          appBar: AppBar(title: Text(cat?.nombre ?? 'Categoría')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _sortButton('Nombre', 'nombre'),
                    const SizedBox(width: 8),
                    _sortButton('Precio', 'precio'),
                    const Spacer(),
                    IconButton(
                      icon: Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 20),
                      onPressed: () => setState(() => _asc = !_asc),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: productos.isEmpty
                    ? const Center(
                        child: Text('Sin productos en esta categoría',
                            style: TextStyle(color: Colors.grey)),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: productos.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) {
                          final p = productos[index];
                          return ProductCard(
                            producto: p,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductoDetalleScreen(productoId: p.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sortButton(String label, String field) {
    final selected = _sortBy == field;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppTheme.textPrimaryColor,
        fontSize: 13,
      ),
      onSelected: (_) => setState(() => _sortBy = field),
    );
  }
}
