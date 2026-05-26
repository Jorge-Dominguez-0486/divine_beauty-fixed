import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../home/home_screen.dart';

class PedidoExitosoScreen extends StatelessWidget {
  final String pedidoId;
  final String metodoPago;

  const PedidoExitosoScreen({
    super.key,
    required this.pedidoId,
    required this.metodoPago,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                '¡Pedido Realizado!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pedido #${pedidoId.length > 8 ? pedidoId.substring(0, 8).toUpperCase() : pedidoId}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _instruccionesPago,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Seguir Comprando',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Ver Mis Pedidos'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _instruccionesPago {
    switch (metodoPago) {
      case 'PayPal':
        return 'Revisa tu email de PayPal para completar el pago';
      case 'Oxxo':
        return 'Recibirás tu referencia por correo en breve';
      default:
        return 'Tu pago está siendo procesado';
    }
  }
}
