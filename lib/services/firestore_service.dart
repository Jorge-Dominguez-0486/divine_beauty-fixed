import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto_model.dart';
import '../models/cupon_model.dart';
import '../models/variante_model.dart';
import '../models/pedido_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String colMarcas = 'marcas';
  static const String colCategorias = 'categorias';
  static const String colProductos = 'productos';
  static const String colVariantes = 'variantes';
  static const String colClientes = 'clientes';
  static const String colPedidos = 'pedidos';
  static const String colDetallePedidos = 'detallePedidos';
  static const String colPagos = 'pagos';
  static const String colResenas = 'resenas';
  static const String colDirecciones = 'direcciones';
  static const String colEnvios = 'envios';
  static const String colFacturas = 'facturas';
  static const String colCupones = 'cupones';
  static const String colProveedores = 'proveedores';
  static const String colOrdenesCompra = 'ordenesCompra';
  static const String colDetalleOrden = 'detalleOrden';

  Future<String> agregar(String coleccion, Map<String, dynamic> datos) async {
    try {
      final doc = await _db.collection(coleccion).add(datos);
      return doc.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> actualizar(
    String coleccion,
    String id,
    Map<String, dynamic> datos,
  ) async {
    try {
      await _db.collection(coleccion).doc(id).update(datos);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminar(String coleccion, String id) async {
    try {
      await _db.collection(coleccion).doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> obtenerPorId(
    String coleccion,
    String id,
  ) async {
    try {
      final doc = await _db.collection(coleccion).doc(id).get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> obtenerTodos(String coleccion) {
    return _db.collection(coleccion).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> obtenerTodosFuture(String coleccion) async {
    try {
      final snapshot = await _db.collection(coleccion).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> obtenerPorCampo(
    String coleccion,
    String campo,
    dynamic valor,
  ) {
    return _db
        .collection(coleccion)
        .where(campo, isEqualTo: valor)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<ProductoModel?> obtenerProducto(String id) async {
    try {
      final data = await obtenerPorId(colProductos, id);
      if (data == null) return null;
      return ProductoModel.fromMap(data, data['id']);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<ProductoModel>> streamProductos() {
    return _db.collection(colProductos).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductoModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<ProductoModel>> streamProductosPorCategoria(
    String categoriaId,
  ) {
    return _db
        .collection(colProductos)
        .where('categoriaId', isEqualTo: categoriaId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductoModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<bool> verificarCupon(String codigo) async {
    try {
      final snapshot = await _db
          .collection(colCupones)
          .where('codigo', isEqualTo: codigo)
          .where('activo', isEqualTo: true)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<CuponModel?> obtenerCuponPorCodigo(String codigo) async {
    try {
      final snapshot = await _db
          .collection(colCupones)
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return CuponModel.fromMap(doc.data(), doc.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> incrementarUsosCupon(String cuponId) async {
    try {
      await _db.collection(colCupones).doc(cuponId).update({
        'usoActual': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<VarianteModel>> obtenerVariantesProducto(
    String productoId,
  ) async {
    try {
      final snapshot = await _db
          .collection(colVariantes)
          .where('productoId', isEqualTo: productoId)
          .get();
      return snapshot.docs
          .map((doc) => VarianteModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<PedidoModel>> streamPedidosCliente(String clienteId) {
    return _db
        .collection(colPedidos)
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PedidoModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
