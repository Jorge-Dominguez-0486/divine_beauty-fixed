import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class DivineButton extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool cargando;
  final Color? color;

  const DivineButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: cargando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(texto, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class DivineInput extends StatelessWidget {
  final String etiqueta;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const DivineInput({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: etiqueta,
        labelStyle: const TextStyle(color: AppTheme.textSecondaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF48FB1), width: 2),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final String? textoBoton;
  final VoidCallback? onBotonPressed;

  const EmptyState({
    super.key,
    required this.mensaje,
    required this.icono,
    this.textoBoton,
    this.onBotonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            if (textoBoton != null && onBotonPressed != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onBotonPressed,
                child: Text(textoBoton!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BeautyLoader extends StatelessWidget {
  const BeautyLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
  }
}

class EstatusBadge extends StatelessWidget {
  final String estatus;

  const EstatusBadge({super.key, required this.estatus});

  Color _color() {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estatus,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
