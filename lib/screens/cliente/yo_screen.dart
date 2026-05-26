import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalogo_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/pedido_model.dart';
import '../../models/direccion_model.dart';
import '../../models/producto_model.dart';
import '../../config/app_theme.dart';
import '../../widgets/product_card.dart';
import '../auth/login_screen.dart';
import 'producto_detalle_screen.dart';
import 'pedido_detalle_screen.dart';

class YoScreen extends StatefulWidget {
  const YoScreen({super.key});

  @override
  State<YoScreen> createState() => _YoScreenState();
}

class _YoScreenState extends State<YoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final usuario = auth.usuario;
        if (usuario == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('Inicia sesión para ver tu perfil',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Iniciar Sesión'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondaryColor,
              indicatorColor: AppTheme.primaryColor,
              tabs: const [
                Tab(icon: Icon(Icons.person), text: 'Perfil'),
                Tab(icon: Icon(Icons.receipt_long), text: 'Pedidos'),
                Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PerfilTab(auth: auth),
                  _PedidosTab(auth: auth, firestore: _firestore),
                  _FavoritosTab(auth: auth),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PerfilTab extends StatefulWidget {
  final AuthProvider auth;
  const _PerfilTab({required this.auth});

  @override
  State<_PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<_PerfilTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _fechaCtrl;
  final _firestore = FirestoreService();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.auth.clienteActual;
    _nombreCtrl = TextEditingController(text: c?.nombre ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _telefonoCtrl = TextEditingController(text: c?.telefono ?? '');
    _fechaCtrl = TextEditingController(text: c?.fechaNacimiento ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  // Sube imagen a Cloudinary (gratuito, sin Firebase Storage)
  Future<String?> _subirImagenCloudinary(XFile imagen) async {
    const cloudName = 'dgxc8kk3k';
    const uploadPreset = 'key_caps';
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final bytes = await imagen.readAsBytes();
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'avatares'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imagen.name,
      ));

    final response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['secure_url'] as String?;
    }
    return null;
  }

  Future<void> _cambiarFoto() async {
    final usuario = widget.auth.usuario;
    if (usuario == null) return;
    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (imagen == null || !mounted) return;

    // Mostrar loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(children: [
          SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 12),
          Text('Subiendo foto...'),
        ]),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final url = await _subirImagenCloudinary(imagen);
      if (url == null) throw Exception('No se pudo subir la imagen');

      await _firestore.actualizar(
        FirestoreService.colClientes,
        usuario.uid,
        {'avatarUrl': url},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Foto actualizada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir foto: $e')),
        );
      }
    }
  }

  Future<void> _guardarPerfil() async {
    final usuario = widget.auth.usuario;
    if (usuario == null || _formKey.currentState == null) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await _firestore.actualizar(
        FirestoreService.colClientes,
        usuario.uid,
        {
          'nombre': _nombreCtrl.text.trim(),
          'telefono': _telefonoCtrl.text.trim(),
          'fechaNacimiento': _fechaCtrl.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _agregarDireccion() {
    final calleCtrl = TextEditingController();
    final coloniaCtrl = TextEditingController();
    final ciudadCtrl = TextEditingController();
    final estadoCtrl = TextEditingController();
    final cpCtrl = TextEditingController();
    bool esPrincipal = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva Dirección'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: calleCtrl,
                  decoration: const InputDecoration(labelText: 'Calle'),
                ),
                TextField(
                  controller: coloniaCtrl,
                  decoration: const InputDecoration(labelText: 'Colonia'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ciudadCtrl,
                        decoration: const InputDecoration(labelText: 'Ciudad'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: estadoCtrl,
                        decoration: const InputDecoration(labelText: 'Estado'),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: cpCtrl,
                  decoration: const InputDecoration(labelText: 'Código Postal'),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: const Text('Dirección principal'),
                  value: esPrincipal,
                  onChanged: (v) => setDialogState(() => esPrincipal = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestore.agregar(
                    FirestoreService.colDirecciones,
                    {
                      'clienteId': widget.auth.usuario?.uid ?? '',
                      'calle': calleCtrl.text,
                      'colonia': coloniaCtrl.text,
                      'ciudad': ciudadCtrl.text,
                      'estado': estadoCtrl.text,
                      'codigoPostal': cpCtrl.text,
                      'esPrincipal': esPrincipal,
                    },
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _eliminarDireccion(String id) async {
    try {
      await _firestore.eliminar(FirestoreService.colDirecciones, id);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.auth.clienteActual;
    final usuario = widget.auth.usuario;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.surfaceColor,
                  backgroundImage: (cliente?.avatarUrl.isNotEmpty == true)
                      ? CachedNetworkImageProvider(cliente!.avatarUrl)
                      : null,
                  child: (cliente?.avatarUrl.isNotEmpty != true)
                      ? Text(
                          (cliente?.nombre ?? usuario?.email ?? 'U')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              fontSize: 32, color: AppTheme.primaryColor),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 16),
                      color: Colors.white,
                      onPressed: _cambiarFoto,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefonoCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fechaCtrl,
              decoration: const InputDecoration(
                labelText: 'Fecha de nacimiento',
                hintText: 'YYYY-MM-DD',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardarPerfil,
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Guardar Cambios'),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mis Direcciones',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: AppTheme.primaryColor),
                  onPressed: _agregarDireccion,
                ),
              ],
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestore.obtenerPorCampo(
                FirestoreService.colDirecciones,
                'clienteId',
                widget.auth.usuario?.uid ?? '',
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Sin direcciones registradas',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                return Column(
                  children: snapshot.data!.map((d) {
                    final dir = DireccionModel.fromMap(d, d['id']);
                    return ListTile(
                      leading: Icon(
                        dir.esPrincipal
                            ? Icons.home
                            : Icons.location_on_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      title: Text('${dir.calle}, ${dir.colonia}'),
                      subtitle: Text('${dir.ciudad}, ${dir.estado}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: Colors.red),
                        onPressed: () => _eliminarDireccion(dir.id),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión'),
              onTap: () => widget.auth.logout(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PedidosTab extends StatelessWidget {
  final AuthProvider auth;
  final FirestoreService firestore;
  const _PedidosTab({required this.auth, required this.firestore});

  static final _formato = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  Color _colorEstatus(String estatus) {
    switch (estatus) {
      case 'pendiente':
        return Colors.orange;
      case 'procesando':
        return Colors.blue;
      case 'enviado':
        return Colors.purple;
      case 'entregado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = auth.usuario?.uid ?? '';
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.obtenerPorCampo(
        FirestoreService.colPedidos,
        'clienteId',
        uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 8),
                Text('Sin pedidos aún', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        final pedidos = snapshot.data!
            .map((d) => PedidoModel.fromMap(d, d['id']))
            .toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final p = pedidos[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${p.id.length > 8 ? p.id.substring(0, 8).toUpperCase() : p.id}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Chip(
                          label: Text(p.estatus,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          backgroundColor: _colorEstatus(p.estatus),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(p.fecha,
                        style: const TextStyle(
                            color: AppTheme.textSecondaryColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(_formato.format(p.total),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primaryColor)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PedidoDetalleScreen(pedido: p),
                          ),
                        ),
                        child: const Text('Ver Detalle'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FavoritosTab extends StatelessWidget {
  final AuthProvider auth;
  const _FavoritosTab({required this.auth});

  void _toggleFavorito(String productoId) {
    final uid = auth.usuario?.uid;
    if (uid == null) return;
    final cliente = auth.clienteActual;
    final favs = List<String>.from(cliente?.favoritos ?? []);
    try {
      if (favs.contains(productoId)) {
        favs.remove(productoId);
        FirebaseFirestore.instance.collection('clientes').doc(uid).update({
          'favoritos': FieldValue.arrayRemove([productoId])
        });
      } else {
        favs.add(productoId);
        FirebaseFirestore.instance.collection('clientes').doc(uid).update({
          'favoritos': FieldValue.arrayUnion([productoId])
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cliente = auth.clienteActual;
    final favoritos = cliente?.favoritos ?? [];
    if (favoritos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text('Sin favoritos aún', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return Consumer<CatalogoProvider>(
      builder: (context, catalogo, _) {
        final productosFav = favoritos
            .map((id) => catalogo.obtenerProductoPorId(id))
            .where((p) => p != null)
            .cast<ProductoModel>()
            .toList();

        if (productosFav.isEmpty) {
          return const Center(
            child: Text('Productos favoritos no disponibles',
                style: TextStyle(color: Colors.grey)),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            itemCount: productosFav.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final p = productosFav[index];
              return Stack(
                children: [
                  ProductCard(
                    producto: p,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductoDetalleScreen(productoId: p.id),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _toggleFavorito(p.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite,
                            color: Colors.red, size: 20),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
