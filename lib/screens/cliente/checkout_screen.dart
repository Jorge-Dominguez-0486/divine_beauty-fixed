// TODO: Integrar SDK de pago real (Stripe/PayPal)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/carrito_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../config/app_theme.dart';
import 'pedido_exitoso_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _pasoActual = 0;
  final _firestore = FirestoreService();
  static final _formato = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  // Dirección
  String _nuevaCalle = '';
  String _nuevaColonia = '';
  String _nuevaCiudad = '';
  String _nuevoEstado = '';
  String _nuevoCP = '';
  String _direccionSeleccionada = '';

  // Pago
  String _metodoPago = 'Tarjeta';
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _cardExpCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  bool _guardando = false;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _cardExpCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  bool get _esValidoPaso1 {
    if (_direccionSeleccionada == 'nueva') {
      return _nuevaCalle.isNotEmpty &&
          _nuevaColonia.isNotEmpty &&
          _nuevaCiudad.isNotEmpty &&
          _nuevoEstado.isNotEmpty &&
          _nuevoCP.isNotEmpty;
    }
    return _direccionSeleccionada.isNotEmpty;
  }

  bool get _esValidoPaso2 {
    // TODO: Validación real de tarjeta cuando se integre SDK
    if (_metodoPago == 'Tarjeta') {
      return _cardNumberCtrl.text.length >= 16 &&
          _cardNameCtrl.text.isNotEmpty &&
          _cardExpCtrl.text.length >= 4 &&
          _cardCvvCtrl.text.length >= 3;
    }
    return true;
  }

  Future<void> _confirmarPedido() async {
    setState(() => _guardando = true);
    final auth = context.read<AuthProvider>();
    final carrito = context.read<CarritoProvider>();

    try {
      final usuario = auth.usuario;
      if (usuario == null) {
        if (mounted) setState(() => _guardando = false);
        return;
      }
      final ahora = DateTime.now().toIso8601String();
      final clienteId = usuario.uid;

      // Crear pedido
      final pedidoId = await _firestore.agregar(
        FirestoreService.colPedidos,
        {
          'clienteId': clienteId,
          'fecha': ahora,
          'estatus': 'pendiente',
          'subtotal': carrito.subtotal,
          'descuento': carrito.descuento,
          'total': carrito.total,
          'metodoPago': _metodoPago,
          'direccionId': _direccionSeleccionada,
        },
      );

      // Crear detalle de pedidos
      for (final item in carrito.items) {
        await _firestore.agregar(
          FirestoreService.colDetallePedidos,
          {
            'pedidoId': pedidoId,
            'varianteId': item.variante?.id ?? '',
            'productoId': item.producto.id,
            'nombreProducto': item.producto.nombre,
            'cantidad': item.cantidad,
            'precioUnitario': item.producto.precio,
          },
        );
      }

      // Crear pago
      // TODO: Integrar SDK de pago real
      await _firestore.agregar(
        FirestoreService.colPagos,
        {
          'pedidoId': pedidoId,
          'metodo': _metodoPago,
          'monto': carrito.total,
          'estatus': 'pendiente',
          'fecha': ahora,
          'referencia': '',
        },
      );

      // Incrementar usos de cupón si se aplicó
      if (carrito.cuponAplicado != null) {
        await _firestore.incrementarUsosCupon(carrito.cuponAplicado!.id);
      }

      carrito.vaciarCarrito();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PedidoExitosoScreen(
              pedidoId: pedidoId,
              metodoPago: _metodoPago,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al procesar pedido: ${e.toString().replaceFirst("Exception: ", "")}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stepper(
        currentStep: _pasoActual,
        onStepContinue: () {
          if (_pasoActual == 0 && !_esValidoPaso1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Completa la dirección de envío')),
            );
            return;
          }
          if (_pasoActual == 1 && !_esValidoPaso2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Completa los datos de pago')),
            );
            return;
          }
          if (_pasoActual < 2) {
            setState(() => _pasoActual++);
          } else {
            _confirmarPedido();
          }
        },
        onStepCancel: () {
          if (_pasoActual > 0) setState(() => _pasoActual--);
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                if (_pasoActual < 2)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Continuar'),
                  )
                else
                  ElevatedButton(
                    onPressed: _guardando ? null : details.onStepContinue,
                    child: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Confirmar Pedido'),
                  ),
                const SizedBox(width: 12),
                if (_pasoActual > 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Atrás'),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Dirección de Envío'),
            isActive: _pasoActual >= 0,
            state: _pasoActual > 0 ? StepState.complete : StepState.indexed,
            content: _buildPasoDireccion(),
          ),
          Step(
            title: const Text('Método de Pago'),
            isActive: _pasoActual >= 1,
            state: _pasoActual > 1 ? StepState.complete : StepState.indexed,
            content: _buildPasoPago(),
          ),
          Step(
            title: const Text('Confirmación'),
            isActive: _pasoActual >= 2,
            state: StepState.indexed,
            content: _buildPasoConfirmacion(),
          ),
        ],
      ),
    );
  }

  Widget _buildPasoDireccion() {
    final auth = context.watch<AuthProvider>();
    final cliente = auth.clienteActual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cliente != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Cliente: ${cliente.nombre}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        RadioListTile<String>(
          title: const Text('Dirección de ejemplo: Calle Principal 123'),
          subtitle: const Text('Col. Centro, Ciudad, CP 12345'),
          value: 'ejemplo1',
          groupValue: _direccionSeleccionada,
          onChanged: (v) => setState(() => _direccionSeleccionada = v!),
        ),
        RadioListTile<String>(
          title: const Text('Agregar nueva dirección'),
          value: 'nueva',
          groupValue: _direccionSeleccionada,
          onChanged: (v) => setState(() => _direccionSeleccionada = v!),
        ),
        if (_direccionSeleccionada == 'nueva') ...[
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(labelText: 'Calle y número'),
            onChanged: (v) => _nuevaCalle = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Colonia'),
            onChanged: (v) => _nuevaColonia = v,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Ciudad'),
                  onChanged: (v) => _nuevaCiudad = v,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Estado'),
                  onChanged: (v) => _nuevoEstado = v,
                ),
              ),
            ],
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Código Postal'),
            keyboardType: TextInputType.number,
            onChanged: (v) => _nuevoCP = v,
          ),
        ],
      ],
    );
  }

  Widget _buildPasoPago() {
    // TODO: Integrar SDK de pago real (Stripe/PayPal)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String>(
          title: const Text('Tarjeta de Crédito/Débito'),
          subtitle: const Text('Visa, Mastercard, American Express'),
          value: 'Tarjeta',
          groupValue: _metodoPago,
          onChanged: (v) => setState(() => _metodoPago = v!),
        ),
        if (_metodoPago == 'Tarjeta') ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Column(
              children: [
                TextField(
                  controller: _cardNumberCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Número de tarjeta',
                    hintText: '1234 5678 9012 3456',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                ),
                TextField(
                  controller: _cardNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del titular',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cardExpCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Vencimiento',
                          hintText: 'MM/AA',
                        ),
                        maxLength: 5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _cardCvvCtrl,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        RadioListTile<String>(
          title: const Text('PayPal'),
          subtitle: const Text('Paga con tu cuenta de PayPal'),
          value: 'PayPal',
          groupValue: _metodoPago,
          onChanged: (v) => setState(() => _metodoPago = v!),
        ),
        if (_metodoPago == 'PayPal')
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Serás redirigido a PayPal para completar el pago',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
        RadioListTile<String>(
          title: const Text('Oxxo'),
          subtitle: const Text('Paga en tienda con efectivo'),
          value: 'Oxxo',
          groupValue: _metodoPago,
          onChanged: (v) => setState(() => _metodoPago = v!),
        ),
        if (_metodoPago == 'Oxxo')
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Se generará una referencia Oxxo para pago en tienda',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
      ],
    );
  }

  Widget _buildPasoConfirmacion() {
    final carrito = context.watch<CarritoProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resumen del Pedido',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        ...carrito.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.cantidad}x ${item.producto.nombre}${item.variante != null ? ' (${item.variante!.tono})' : ''}',
                    ),
                  ),
                  Text(_formato.format(item.subtotal)),
                ],
              ),
            )),
        const Divider(),
        _resumenLinea('Subtotal', _formato.format(carrito.subtotal)),
        if (carrito.descuento > 0)
          _resumenLinea('Descuento', '-${_formato.format(carrito.descuento)}',
              color: Colors.green),
        _resumenLinea('Total', _formato.format(carrito.total), bold: true),
        const SizedBox(height: 16),
        const Text('Dirección de Envío',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const Text(
            'Calle Principal 123, Col. Centro, Ciudad, CP 12345'),
        const SizedBox(height: 8),
        const Text('Método de Pago',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text('$_metodoPago'),
      ],
    );
  }

  Widget _resumenLinea(String label, String valor,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(valor,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}
