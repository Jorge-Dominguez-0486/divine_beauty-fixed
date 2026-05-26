import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../models/variante_model.dart';
import '../models/cupon_model.dart';
import '../services/firestore_service.dart';

class ItemCarrito {
  final ProductoModel producto;
  final VarianteModel? variante;
  int cantidad;

  ItemCarrito({
    required this.producto,
    this.variante,
    required this.cantidad,
  });

  double get subtotal => producto.precio * cantidad;

  String get keyId => '${producto.id}_${variante?.id ?? ''}';
}

class CarritoProvider extends ChangeNotifier {
  final List<ItemCarrito> _items = [];
  String? _codigoCupon;
  CuponModel? _cuponAplicado;
  double _descuento = 0.0;

  List<ItemCarrito> get items => List.unmodifiable(_items);
  String? get codigoCupon => _codigoCupon;
  CuponModel? get cuponAplicado => _cuponAplicado;
  double get descuento => _descuento;

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.cantidad);
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get total {
    final t = subtotal - _descuento;
    return t < 0 ? 0 : t;
  }

  bool get estaVacio => _items.isEmpty;

  void agregarItem(ProductoModel producto, VarianteModel? variante, int cantidad) {
    final key = '${producto.id}_${variante?.id ?? ''}';
    final index = _items.indexWhere((i) => i.keyId == key);
    if (index >= 0) {
      _items[index].cantidad += cantidad;
    } else {
      _items.add(ItemCarrito(
        producto: producto,
        variante: variante,
        cantidad: cantidad,
      ));
    }
    notifyListeners();
  }

  void quitarItem(String productoId, String? varianteId) {
    final key = '${productoId}_${varianteId ?? ''}';
    _items.removeWhere((i) => i.keyId == key);
    if (_items.isEmpty) quitarCupon();
    notifyListeners();
  }

  void cambiarCantidad(String productoId, String? varianteId, int nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      quitarItem(productoId, varianteId);
      return;
    }
    final key = '${productoId}_${varianteId ?? ''}';
    final index = _items.indexWhere((i) => i.keyId == key);
    if (index >= 0) {
      _items[index].cantidad = nuevaCantidad;
      notifyListeners();
    }
  }

  void vaciarCarrito() {
    _items.clear();
    quitarCupon();
    notifyListeners();
  }

  Future<bool> aplicarCupon(String codigo, FirestoreService firestoreService) async {
    try {
      final cupon = await firestoreService.obtenerCuponPorCodigo(codigo);
      if (cupon == null) return false;
      if (!cupon.activo) return false;
      if (cupon.usoMaximo > 0 && cupon.usoActual >= cupon.usoMaximo) return false;

    _codigoCupon = codigo;
    _cuponAplicado = cupon;

    if (cupon.tipoDescuento == 'porcentaje') {
      _descuento = subtotal * (cupon.valor / 100);
    } else {
      _descuento = cupon.valor > subtotal ? subtotal : cupon.valor;
    }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void quitarCupon() {
    _codigoCupon = null;
    _cuponAplicado = null;
    _descuento = 0.0;
    notifyListeners();
  }
}
