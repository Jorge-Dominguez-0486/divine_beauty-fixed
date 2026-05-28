import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../services/firestore_service.dart';
import '../../config/app_theme.dart';
import '../home/home_screen.dart';

// ✅ CORRECCIÓN: se agrega el tipo "imagen" al enum
enum AdminFieldType { texto, numero, booleano, seleccion, imagen, relacionFB }

class AdminField {
  final String nombre;
  final String etiqueta;
  final AdminFieldType tipo;
  final bool requerido;
  final List<String>? opciones;
  final String? coleccionRef; // colección de Firestore para tipo relacionFB
  const AdminField(this.nombre, this.etiqueta, this.tipo,
      {this.requerido = false, this.opciones, this.coleccionRef});
}

class AdminConfig {
  static const List<AdminField> marcas = [
    AdminField('nombre', 'Nombre', AdminFieldType.texto, requerido: true),
    AdminField('paisOrigen', 'País de Origen', AdminFieldType.texto),
    AdminField('descripcion', 'Descripción', AdminFieldType.texto),
    AdminField('activo', 'Activo', AdminFieldType.booleano),
  ];
  static const List<AdminField> categorias = [
    AdminField('nombre', 'Nombre', AdminFieldType.texto, requerido: true),
    AdminField('descripcion', 'Descripción', AdminFieldType.texto),
    AdminField('colorHex', 'Color Hex', AdminFieldType.texto),
  ];
  static const List<AdminField> productos = [
    AdminField('nombre', 'Nombre', AdminFieldType.texto, requerido: true),
    AdminField('descripcion', 'Descripción', AdminFieldType.texto),
    AdminField('precio', 'Precio', AdminFieldType.numero, requerido: true),
    AdminField('stock', 'Stock', AdminFieldType.numero),
    AdminField('categoriaId', 'Categoría', AdminFieldType.relacionFB,
        coleccionRef: FirestoreService.colCategorias, requerido: true),
    AdminField('marcaId', 'Marca', AdminFieldType.relacionFB,
        coleccionRef: FirestoreService.colMarcas),
    // ✅ CORRECCIÓN: campo imagen en lugar de texto plano
    AdminField(
        'imagenPrincipalUrl', 'Imagen del Producto', AdminFieldType.imagen),
    AdminField('activo', 'Activo', AdminFieldType.booleano),
  ];
  static const List<AdminField> variantes = [
    AdminField('productoId', 'ID Producto', AdminFieldType.texto,
        requerido: true),
    AdminField('tono', 'Tono', AdminFieldType.texto, requerido: true),
    AdminField('codigoHex', 'Código HEX', AdminFieldType.texto),
    AdminField('stock', 'Stock', AdminFieldType.numero),
    AdminField('sku', 'SKU', AdminFieldType.texto),
  ];
  static const List<AdminField> clientes = [
    AdminField('nombre', 'Nombre', AdminFieldType.texto),
    AdminField('email', 'Email', AdminFieldType.texto),
    AdminField('telefono', 'Teléfono', AdminFieldType.texto),
    AdminField('fechaNacimiento', 'Fecha Nacimiento', AdminFieldType.texto),
  ];
  static const List<AdminField> pedidos = [
    AdminField('clienteId', 'ID Cliente', AdminFieldType.texto),
    AdminField('fecha', 'Fecha', AdminFieldType.texto),
    AdminField('estatus', 'Estatus', AdminFieldType.seleccion, opciones: [
      'pendiente',
      'procesando',
      'enviado',
      'entregado',
      'cancelado'
    ]),
    AdminField('subtotal', 'Subtotal', AdminFieldType.numero),
    AdminField('descuento', 'Descuento', AdminFieldType.numero),
    AdminField('total', 'Total', AdminFieldType.numero),
    AdminField('metodoPago', 'Método de Pago', AdminFieldType.seleccion,
        opciones: ['PayPal', 'Tarjeta', 'Oxxo']),
  ];
  static const List<AdminField> detallePedidos = [
    AdminField('pedidoId', 'ID Pedido', AdminFieldType.texto, requerido: true),
    AdminField('productoId', 'ID Producto', AdminFieldType.texto),
    AdminField('nombreProducto', 'Nombre Producto', AdminFieldType.texto),
    AdminField('cantidad', 'Cantidad', AdminFieldType.numero),
    AdminField('precioUnitario', 'Precio Unitario', AdminFieldType.numero),
  ];
  static const List<AdminField> pagos = [
    AdminField('pedidoId', 'ID Pedido', AdminFieldType.texto),
    AdminField('metodo', 'Método', AdminFieldType.seleccion,
        opciones: ['PayPal', 'Tarjeta', 'Oxxo']),
    AdminField('monto', 'Monto', AdminFieldType.numero),
    AdminField('estatus', 'Estatus', AdminFieldType.seleccion,
        opciones: ['pendiente', 'completado', 'fallido']),
    AdminField('referencia', 'Referencia', AdminFieldType.texto),
    AdminField('fecha', 'Fecha', AdminFieldType.texto),
  ];
  static const List<AdminField> resenas = [
    AdminField('clienteId', 'ID Cliente', AdminFieldType.texto),
    AdminField('productoId', 'ID Producto', AdminFieldType.texto),
    AdminField('calificacion', 'Calificación (1-5)', AdminFieldType.numero),
    AdminField('comentario', 'Comentario', AdminFieldType.texto),
    AdminField('fecha', 'Fecha', AdminFieldType.texto),
    AdminField('nombreCliente', 'Nombre Cliente', AdminFieldType.texto),
  ];
  static const List<AdminField> direcciones = [
    AdminField('clienteId', 'ID Cliente', AdminFieldType.texto),
    AdminField('calle', 'Calle', AdminFieldType.texto),
    AdminField('colonia', 'Colonia', AdminFieldType.texto),
    AdminField('ciudad', 'Ciudad', AdminFieldType.texto),
    AdminField('estado', 'Estado', AdminFieldType.texto),
    AdminField('codigoPostal', 'Código Postal', AdminFieldType.texto),
    AdminField('esPrincipal', 'Es Principal', AdminFieldType.booleano),
  ];
  static const List<AdminField> envios = [
    AdminField('pedidoId', 'ID Pedido', AdminFieldType.texto),
    AdminField('numGuia', 'Número de Guía', AdminFieldType.texto),
    AdminField('paqueteria', 'Paquetería', AdminFieldType.texto),
    AdminField('fechaEstimada', 'Fecha Estimada', AdminFieldType.texto),
    AdminField('estatus', 'Estatus', AdminFieldType.texto),
  ];
  static const List<AdminField> facturas = [
    AdminField('pedidoId', 'ID Pedido', AdminFieldType.texto),
    AdminField('rfc', 'RFC', AdminFieldType.texto),
    AdminField('razonSocial', 'Razón Social', AdminFieldType.texto),
    AdminField('usoCFDI', 'Uso CFDI', AdminFieldType.texto),
    AdminField('fecha', 'Fecha', AdminFieldType.texto),
  ];
  static const List<AdminField> cupones = [
    AdminField('codigo', 'Código', AdminFieldType.texto, requerido: true),
    AdminField('tipoDescuento', 'Tipo', AdminFieldType.seleccion,
        opciones: ['porcentaje', 'monto_fijo']),
    AdminField('valor', 'Valor', AdminFieldType.numero, requerido: true),
    AdminField('vigencia', 'Vigencia', AdminFieldType.texto),
    AdminField('usoMaximo', 'Uso Máximo', AdminFieldType.numero),
    AdminField('activo', 'Activo', AdminFieldType.booleano),
  ];
  static const List<AdminField> proveedores = [
    AdminField('nombre', 'Nombre', AdminFieldType.texto, requerido: true),
    AdminField('contacto', 'Contacto', AdminFieldType.texto),
    AdminField('email', 'Email', AdminFieldType.texto),
    AdminField('telefono', 'Teléfono', AdminFieldType.texto),
    AdminField('pais', 'País', AdminFieldType.texto),
    AdminField('activo', 'Activo', AdminFieldType.booleano),
  ];
  static const List<AdminField> ordenesCompra = [
    AdminField('proveedorId', 'ID Proveedor', AdminFieldType.texto),
    AdminField('fecha', 'Fecha', AdminFieldType.texto),
    AdminField('estatus', 'Estatus', AdminFieldType.seleccion,
        opciones: ['borrador', 'enviada', 'recibida', 'cancelada']),
    AdminField('total', 'Total', AdminFieldType.numero),
    AdminField('notas', 'Notas', AdminFieldType.texto),
  ];
  static const List<AdminField> detalleOrden = [
    AdminField('ordenCompraId', 'ID Orden', AdminFieldType.texto),
    AdminField('productoNombre', 'Producto', AdminFieldType.texto),
    AdminField('cantidad', 'Cantidad', AdminFieldType.numero),
    AdminField('precioCosto', 'Precio Costo', AdminFieldType.numero),
  ];

  static List<AdminField> getConfig(String coleccion) {
    switch (coleccion) {
      case FirestoreService.colMarcas:
        return marcas;
      case FirestoreService.colCategorias:
        return categorias;
      case FirestoreService.colProductos:
        return productos;
      case FirestoreService.colVariantes:
        return variantes;
      case FirestoreService.colClientes:
        return clientes;
      case FirestoreService.colPedidos:
        return pedidos;
      case FirestoreService.colDetallePedidos:
        return detallePedidos;
      case FirestoreService.colPagos:
        return pagos;
      case FirestoreService.colResenas:
        return resenas;
      case FirestoreService.colDirecciones:
        return direcciones;
      case FirestoreService.colEnvios:
        return envios;
      case FirestoreService.colFacturas:
        return facturas;
      case FirestoreService.colCupones:
        return cupones;
      case FirestoreService.colProveedores:
        return proveedores;
      case FirestoreService.colOrdenesCompra:
        return ordenesCompra;
      case FirestoreService.colDetalleOrden:
        return detalleOrden;
      default:
        return [];
    }
  }
}

class _DrawerItem {
  final String titulo;
  final IconData icon;
  final String coleccion;
  _DrawerItem(this.titulo, this.icon, this.coleccion);
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirestoreService _firestore = FirestoreService();
  String _coleccionActual = FirestoreService.colMarcas;

  final List<_DrawerItem> _items = [
    _DrawerItem('Marcas', Icons.bookmark, FirestoreService.colMarcas),
    _DrawerItem('Categorías', Icons.folder, FirestoreService.colCategorias),
    _DrawerItem('Productos', Icons.inventory_2, FirestoreService.colProductos),
    _DrawerItem('Variantes', Icons.palette, FirestoreService.colVariantes),
    _DrawerItem('Clientes', Icons.people, FirestoreService.colClientes),
    _DrawerItem('Pedidos', Icons.receipt_long, FirestoreService.colPedidos),
    _DrawerItem(
        'Detalle Pedidos', Icons.list_alt, FirestoreService.colDetallePedidos),
    _DrawerItem('Pagos', Icons.payments, FirestoreService.colPagos),
    _DrawerItem('Reseñas', Icons.star, FirestoreService.colResenas),
    _DrawerItem(
        'Direcciones', Icons.location_on, FirestoreService.colDirecciones),
    _DrawerItem('Envíos', Icons.local_shipping, FirestoreService.colEnvios),
    _DrawerItem('Facturas', Icons.description, FirestoreService.colFacturas),
    _DrawerItem(
        'Cupones', Icons.confirmation_number, FirestoreService.colCupones),
    _DrawerItem('Proveedores', Icons.factory, FirestoreService.colProveedores),
    _DrawerItem('Órdenes Compra', Icons.shopping_cart,
        FirestoreService.colOrdenesCompra),
    _DrawerItem('Detalle Órdenes', Icons.format_list_bulleted,
        FirestoreService.colDetalleOrden),
  ];

  Widget _buildDrawerContent() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 16,
          ),
          width: double.infinity,
          color: AppTheme.primaryColor,
          child: Column(
            children: [
              const Icon(Icons.admin_panel_settings,
                  size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text('Divine Beauty',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text('Panel de Administración',
                  style: GoogleFonts.montserrat(
                      fontSize: 12, color: Colors.white70)),
            ],
          ),
        ),
        // ── BOTÓN VER TIENDA ──
        ListTile(
          leading: const Icon(Icons.storefront, color: Colors.white),
          title: const Text('Ver Tienda',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          tileColor: Colors.pink.shade300,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final selected = item.coleccion == _coleccionActual;
              return ListTile(
                leading: Icon(item.icon,
                    color: selected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade700),
                title: Text(item.titulo,
                    style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      color: selected
                          ? AppTheme.primaryColor
                          : Colors.grey.shade800,
                    )),
                selected: selected,
                selectedTileColor: AppTheme.surfaceColor,
                onTap: () {
                  setState(() => _coleccionActual = item.coleccion);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Panel Admin — Divine Beauty',
          style: GoogleFonts.playfairDisplay(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ),
            icon: const Icon(Icons.storefront, color: Colors.white),
            label:
                const Text('Ver Tienda', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: Drawer(child: _buildDrawerContent()),
      body: _coleccionActual == FirestoreService.colClientes
          ? ClientesAdminWidget(firestore: _firestore)
          : AdminCrudWidget(
              coleccion: _coleccionActual,
              firestore: _firestore,
            ),
    );
  }
}

// ══════════════════════════════════════════════
// WIDGET ESPECIAL PARA CLIENTES (con toggle de rol)
// ══════════════════════════════════════════════
class ClientesAdminWidget extends StatefulWidget {
  final FirestoreService firestore;
  const ClientesAdminWidget({super.key, required this.firestore});
  @override
  State<ClientesAdminWidget> createState() => _ClientesAdminWidgetState();
}

class _ClientesAdminWidgetState extends State<ClientesAdminWidget> {
  String _filtro = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleAdmin(String clienteId, bool valorActual) async {
    final nuevoValor = !valorActual;
    final accion = nuevoValor ? 'administrador' : 'usuario normal';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar Rol'),
        content: Text('¿Cambiar este cliente a $accion?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await FirebaseFirestore.instance
          .collection(FirestoreService.colClientes)
          .doc(clienteId)
          .update({'esAdmin': nuevoValor});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol cambiado a $accion'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _eliminarCliente(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: const Text(
            '¿Estás segura de eliminar este cliente? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await widget.firestore.eliminar(FirestoreService.colClientes, id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente eliminado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar cliente por nombre o email...',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _filtro = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: widget.firestore.obtenerTodos(FirestoreService.colClientes),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data ?? [];
              final filtrados = _filtro.isEmpty
                  ? items
                  : items.where((c) {
                      final nombre =
                          (c['nombre'] ?? '').toString().toLowerCase();
                      final email = (c['email'] ?? '').toString().toLowerCase();
                      return nombre.contains(_filtro) ||
                          email.contains(_filtro);
                    }).toList();

              if (filtrados.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('Sin clientes registrados',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final cliente = filtrados[index];
                  final esAdmin = cliente['esAdmin'] == true;
                  final nombre = cliente['nombre'] ?? 'Sin nombre';
                  final email = cliente['email'] ?? '';
                  final id = cliente['id'] ?? '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: esAdmin
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                        child: Text(
                          nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                          style: TextStyle(
                            color:
                                esAdmin ? Colors.white : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: esAdmin
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              esAdmin ? '👑 Administrador' : '👤 Usuario',
                              style: TextStyle(
                                fontSize: 11,
                                color: esAdmin
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: esAdmin ? 'Quitar admin' : 'Hacer admin',
                            child: IconButton(
                              icon: Icon(
                                esAdmin
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                color: esAdmin
                                    ? AppTheme.primaryColor
                                    : Colors.grey,
                              ),
                              onPressed: () => _toggleAdmin(id, esAdmin),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarCliente(id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// WIDGET CRUD GENÉRICO
// ══════════════════════════════════════════════
class AdminCrudWidget extends StatefulWidget {
  final String coleccion;
  final FirestoreService firestore;
  const AdminCrudWidget(
      {super.key, required this.coleccion, required this.firestore});
  @override
  State<AdminCrudWidget> createState() => _AdminCrudWidgetState();
}

class _AdminCrudWidgetState extends State<AdminCrudWidget> {
  List<AdminField> get _campos => AdminConfig.getConfig(widget.coleccion);
  String _filtro = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _valorCampo(Map<String, dynamic> item, AdminField campo) {
    final valor = item[campo.nombre];
    if (valor == null) return '-';
    if (campo.tipo == AdminFieldType.booleano)
      return valor == true ? 'Sí' : 'No';
    return valor.toString();
  }

  Future<void> _eliminar(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás segura de eliminar este registro?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await widget.firestore.eliminar(widget.coleccion, id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Registro eliminado')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Error: ${e.toString().replaceFirst("Exception: ", "")}')));
      }
    }
  }

  void _abrirFormulario({Map<String, dynamic>? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => AdminFormDialog(
        campos: _campos,
        datosExistentes: item,
        onGuardar: (datos) async {
          try {
            if (item != null) {
              await widget.firestore
                  .actualizar(widget.coleccion, item['id'], datos);
            } else {
              await widget.firestore.agregar(widget.coleccion, datos);
            }
            if (mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(item != null
                      ? 'Registro actualizado'
                      : 'Registro creado')));
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'Error: ${e.toString().replaceFirst("Exception: ", "")}')));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _filtro = v.toLowerCase()),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                heroTag: 'add_${widget.coleccion}',
                onPressed: () => _abrirFormulario(),
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: widget.firestore.obtenerTodos(widget.coleccion),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final items = snapshot.data ?? [];
              final filtrados = _filtro.isEmpty
                  ? items
                  : items
                      .where((item) => item.values.any(
                          (v) => v.toString().toLowerCase().contains(_filtro)))
                      .toList();

              if (filtrados.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.inbox_outlined,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(items.isEmpty ? 'Sin registros aún' : 'Sin resultados',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600)),
                  ]),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final item = filtrados[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._campos.map((campo) {
                            if (campo.tipo == AdminFieldType.imagen) {
                              final url = item[campo.nombre]?.toString() ?? '';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(campo.etiqueta,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    const SizedBox(height: 4),
                                    if (url.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          url,
                                          height: 140,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            height: 140,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                                child: Icon(Icons.broken_image,
                                                    color: Colors.grey)),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.image_outlined,
                                              size: 32, color: Colors.grey),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      child: Text('${campo.etiqueta}:',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                    ),
                                    Expanded(
                                      child: Text(_valorCampo(item, campo)),
                                    ),
                                  ]),
                            );
                          }),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    size: 20, color: AppTheme.primaryColor),
                                onPressed: () => _abrirFormulario(item: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 20, color: Colors.red),
                                onPressed: () => _eliminar(item['id']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// FORMULARIO GENÉRICO
// ══════════════════════════════════════════════
class AdminFormDialog extends StatefulWidget {
  final List<AdminField> campos;
  final Map<String, dynamic>? datosExistentes;
  final Function(Map<String, dynamic>) onGuardar;
  const AdminFormDialog(
      {super.key,
      required this.campos,
      this.datosExistentes,
      required this.onGuardar});
  @override
  State<AdminFormDialog> createState() => _AdminFormDialogState();
}

class _AdminFormDialogState extends State<AdminFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _valores;
  bool _guardando = false;
  // ✅ CORRECCIÓN: mapa para controlar si se está subiendo imagen por campo
  final Map<String, bool> _subiendoImagen = {};

  @override
  void initState() {
    super.initState();
    _valores = {};
    for (final campo in widget.campos) {
      final existente = widget.datosExistentes?[campo.nombre];
      if (campo.tipo == AdminFieldType.booleano) {
        _valores[campo.nombre] = existente ?? false;
      } else {
        _valores[campo.nombre] = existente?.toString() ?? '';
      }
    }
  }

  // ✅ CORRECCIÓN: método para subir imagen a Firebase Storage
  // Sube imagen a Cloudinary (funciona en Web, Android, iOS, Windows)
  Future<void> _subirImagen(String nombreCampo, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    setState(() => _subiendoImagen[nombreCampo] = true);

    try {
      final bytes = await picked.readAsBytes();
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/dgxc8kk3k/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'key_caps'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));

      final response = await request.send().timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw Exception('Tiempo agotado. Verifica tu conexión.'),
          );

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        final url = json['secure_url'] as String;

        setState(() {
          _valores[nombreCampo] = url;
          _subiendoImagen[nombreCampo] = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen subida correctamente ✓'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        final body = await response.stream.bytesToString();
        throw Exception('Cloudinary error ${response.statusCode}: $body');
      }
    } catch (e) {
      setState(() => _subiendoImagen[nombreCampo] = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.datosExistentes != null
                    ? 'Editar Registro'
                    : 'Nuevo Registro',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor),
              ),
              const SizedBox(height: 20),
              ...widget.campos.map((campo) => _construirCampo(campo)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _guardando ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor),
                    onPressed: _guardando ? null : _submit,
                    child: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Guardar',
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCampo(AdminField campo) {
    switch (campo.tipo) {
      case AdminFieldType.booleano:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SwitchListTile(
            title: Text(campo.etiqueta),
            value: _valores[campo.nombre] ?? false,
            activeColor: AppTheme.primaryColor,
            onChanged: (v) => setState(() => _valores[campo.nombre] = v),
          ),
        );

      case AdminFieldType.seleccion:
        final opciones = campo.opciones ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: campo.etiqueta,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            value: _valores[campo.nombre]?.toString().isNotEmpty == true
                ? _valores[campo.nombre].toString()
                : null,
            items: opciones
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (v) => setState(() => _valores[campo.nombre] = v ?? ''),
            validator: campo.requerido
                ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null
                : null,
          ),
        );

      case AdminFieldType.relacionFB:
        final colRef = campo.coleccionRef ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection(colRef).get().then(
                  (s) => s.docs.map((d) {
                    final data = d.data();
                    data['id'] = d.id;
                    return data;
                  }).toList(),
                ),
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              final currentVal = _valores[campo.nombre]?.toString();
              // Si el valor actual no está en la lista, lo limpiamos
              final validVal =
                  items.any((i) => i['id'] == currentVal) ? currentVal : null;
              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: campo.etiqueta,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                value: validVal,
                hint: snapshot.connectionState == ConnectionState.waiting
                    ? const Text('Cargando...')
                    : Text('Seleccionar ${campo.etiqueta}'),
                items: items
                    .map((item) => DropdownMenuItem<String>(
                          value: item['id'] as String,
                          child: Text(item['nombre'] ?? item['id']),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _valores[campo.nombre] = v ?? ''),
                validator: campo.requerido
                    ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null
                    : null,
              );
            },
          ),
        );

      // ✅ CORRECCIÓN: nuevo caso para campos de imagen
      case AdminFieldType.imagen:
        final urlActual = _valores[campo.nombre]?.toString() ?? '';
        final subiendo = _subiendoImagen[campo.nombre] == true;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(campo.etiqueta,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              // Vista previa de la imagen si ya hay URL
              if (urlActual.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    urlActual,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: Colors.grey.shade200,
                      child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 48, color: Colors.grey)),
                    ),
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            height: 160,
                            color: Colors.grey.shade100,
                            child: const Center(
                                child: CircularProgressIndicator())),
                  ),
                )
              else
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Center(
                    child: Icon(Icons.image_outlined,
                        size: 48, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 8),
              // Campo de URL manual
              TextFormField(
                key: ValueKey('url_${campo.nombre}_$urlActual'),
                initialValue: urlActual,
                decoration: InputDecoration(
                  labelText: 'URL de imagen (opcional)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  suffixIcon: urlActual.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () =>
                              setState(() => _valores[campo.nombre] = ''),
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _valores[campo.nombre] = v),
              ),
              const SizedBox(height: 8),
              // Botones para subir imagen
              if (subiendo)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('Subiendo imagen...'),
                      ],
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text('Galería'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                        ),
                        onPressed: () =>
                            _subirImagen(campo.nombre, ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('Cámara'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                        ),
                        onPressed: () =>
                            _subirImagen(campo.nombre, ImageSource.camera),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );

      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: campo.etiqueta,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: campo.tipo == AdminFieldType.numero
                ? TextInputType.number
                : TextInputType.text,
            initialValue: _valores[campo.nombre].toString(),
            validator: campo.requerido
                ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null
                : null,
            onChanged: (v) => _valores[campo.nombre] = v,
          ),
        );
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate())
      return;
    setState(() => _guardando = true);
    final datos = <String, dynamic>{};
    for (final campo in widget.campos) {
      final valor = _valores[campo.nombre];
      if (campo.tipo == AdminFieldType.numero) {
        datos[campo.nombre] = double.tryParse(valor?.toString() ?? '') ?? 0;
      } else if (campo.tipo == AdminFieldType.booleano) {
        datos[campo.nombre] = valor ?? false;
      } else {
        datos[campo.nombre] = valor?.toString() ?? '';
      }
    }
    await widget.onGuardar(datos);
    if (mounted) setState(() => _guardando = false);
  }
}
