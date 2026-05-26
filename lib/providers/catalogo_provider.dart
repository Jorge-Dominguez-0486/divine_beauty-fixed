import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto_model.dart';
import '../models/categoria_model.dart';
import '../models/marca_model.dart';
import '../services/firestore_service.dart';

class CatalogoProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<ProductoModel> _productos = [];
  List<CategoriaModel> _categorias = [];
  List<MarcaModel> _marcas = [];
  bool _cargando = false;
  String? _categoriaFiltro;

  List<ProductoModel> get productos => _productos;
  List<CategoriaModel> get categorias => _categorias;
  List<MarcaModel> get marcas => _marcas;
  bool get cargando => _cargando;
  String? get categoriaFiltro => _categoriaFiltro;

  List<ProductoModel> get productosFiltrados {
    if (_categoriaFiltro == null) return _productos;
    return _productos.where((p) => p.categoriaId == _categoriaFiltro).toList();
  }

  List<ProductoModel> get destacados {
    return _productos.where((p) => p.activo).take(6).toList();
  }

  List<ProductoModel> get novedades {
    return _productos.reversed.where((p) => p.activo).take(8).toList();
  }

  void inicializar() {
    _cargarCategorias();
    _cargarMarcas();
    _escucharProductos();
  }

  void _escucharProductos() {
    _firestore.obtenerTodos(FirestoreService.colProductos).listen((data) {
      _productos = data
          .map((d) => ProductoModel.fromMap(d, d['id']))
          .toList();
      notifyListeners();
    }, onError: (error) {
      debugPrint('Productos stream error: $error');
    });
  }

  void _cargarCategorias() {
    _firestore.obtenerTodos(FirestoreService.colCategorias).listen((data) {
      _categorias = data
          .map((d) => CategoriaModel.fromMap(d, d['id']))
          .toList();
      notifyListeners();
    }, onError: (error) {
      debugPrint('Categorias stream error: $error');
    });
  }

  void _cargarMarcas() {
    _firestore.obtenerTodos(FirestoreService.colMarcas).listen((data) {
      _marcas = data
          .map((d) => MarcaModel.fromMap(d, d['id']))
          .toList();
      notifyListeners();
    }, onError: (error) {
      debugPrint('Marcas stream error: $error');
    });
  }

  void filtrarPorCategoria(String? categoriaId) {
    _categoriaFiltro = categoriaId;
    notifyListeners();
  }

  ProductoModel? obtenerProductoPorId(String id) {
    try {
      return _productos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  CategoriaModel? obtenerCategoriaPorId(String id) {
    try {
      return _categorias.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  MarcaModel? obtenerMarcaPorId(String id) {
    try {
      return _marcas.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
