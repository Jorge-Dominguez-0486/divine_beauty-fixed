import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/pedido_model.dart';
import '../../models/detalle_pedido_model.dart';
import '../../models/pago_model.dart';
import '../../models/envio_model.dart';
import '../../config/app_theme.dart';

class PedidoDetalleScreen extends StatefulWidget {
  final PedidoModel pedido;

  const PedidoDetalleScreen({super.key, required this.pedido});

  @override
  State<PedidoDetalleScreen> createState() => _PedidoDetalleScreenState();
}

class _PedidoDetalleScreenState extends State<PedidoDetalleScreen> {
  final _firestore = FirestoreService();
  List<DetallePedidoModel> _detalles = [];
  PagoModel? _pago;
  EnvioModel? _envio;

  static final _formato = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final detalleSnapshot = await _firestore.obtenerPorCampo(
        FirestoreService.colDetallePedidos,
        'pedidoId',
        widget.pedido.id,
      ).first;
      final pagoSnapshot = await _firestore.obtenerPorCampo(
        FirestoreService.colPagos,
        'pedidoId',
        widget.pedido.id,
      ).first;
      final envioSnapshot = await _firestore.obtenerPorCampo(
        FirestoreService.colEnvios,
        'pedidoId',
        widget.pedido.id,
      ).first;

      if (mounted) {
        setState(() {
          _detalles = detalleSnapshot
              .map((d) => DetallePedidoModel.fromMap(d, d['id']))
              .toList();
          if (pagoSnapshot.isNotEmpty) {
            _pago = PagoModel.fromMap(pagoSnapshot.first, pagoSnapshot.first['id']);
          }
          if (envioSnapshot.isNotEmpty) {
            _envio = EnvioModel.fromMap(envioSnapshot.first, envioSnapshot.first['id']);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _mostrarDialogResena(DetallePedidoModel detalle) async {
    int calificacion = 5;
    final comentarioCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Califica tu compra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detalle.nombreProducto,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < calificacion ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => calificacion = i + 1),
                  );
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: comentarioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Comentario (opcional)',
                  hintText: 'Cuéntanos tu experiencia...',
                ),
                maxLines: 3,
                maxLength: 300,
              ),
            ],
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
                    FirestoreService.colResenas,
                    {
                      'clienteId': widget.pedido.clienteId,
                      'productoId': detalle.productoId,
                      'calificacion': calificacion,
                      'comentario': comentarioCtrl.text,
                      'fecha': DateTime.now().toIso8601String(),
                      'nombreCliente': '',
                    },
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reseña enviada')),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al enviar reseña: $e')),
                    );
                  }
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '#${p.id.length > 8 ? p.id.substring(0, 8).toUpperCase() : p.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(p.estatus,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  backgroundColor: _colorEstatus(p.estatus),
                ),
                Text(p.fecha,
                    style: const TextStyle(
                        color: AppTheme.textSecondaryColor)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Productos',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (_detalles.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ..._detalles.map((d) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.nombreProducto,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text('Cantidad: ${d.cantidad}',
                                    style: const TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                          Text(_formato.format(d.precioUnitario),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor)),
                          if (p.estatus == 'entregado') ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.rate_review,
                                  color: AppTheme.primaryColor, size: 20),
                              onPressed: () => _mostrarDialogResena(d),
                              tooltip: 'Dejar reseña',
                            ),
                          ],
                        ],
                      ),
                    ),
                  )),
            const SizedBox(height: 16),
            const Text('Pago',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (_pago != null) ...[
                      _linea('Método', _pago!.metodo),
                      _linea('Referencia', _pago!.referencia.isNotEmpty
                          ? _pago!.referencia
                          : 'Pendiente'),
                      _linea('Estatus', _pago!.estatus),
                    ] else
                      const Text('Información de pago no disponible'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_envio != null) ...[
              const Text('Envío',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _linea('Guía', _envio!.numGuia.isNotEmpty
                          ? _envio!.numGuia
                          : 'Pendiente'),
                      _linea('Paquetería', _envio!.paqueteria.isNotEmpty
                          ? _envio!.paqueteria
                          : 'Pendiente'),
                      _linea('Estatus', _envio!.estatus.isNotEmpty
                          ? _envio!.estatus
                          : 'Pendiente'),
                      if (_envio!.fechaEstimada.isNotEmpty)
                        _linea('Fecha estimada', _envio!.fechaEstimada),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total pagado',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(_formato.format(p.total),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.primaryColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linea(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppTheme.textSecondaryColor)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
