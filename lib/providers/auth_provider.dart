import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/cliente_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _usuario;
  ClienteModel? _clienteActual;
  bool _cargando = false;
  String? _error;

  User? get usuario => _usuario;
  ClienteModel? get clienteActual => _clienteActual;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaAutenticado => _usuario != null;

  void inicializar() {
    _authService.estadoAuth.listen((user) async {
      _usuario = user;
      if (user != null) {
        await _cargarCliente(user.uid);
      } else {
        _clienteActual = null;
      }
      notifyListeners();
    }, onError: (error) {
      debugPrint('Auth stream error: $error');
    });
  }

  Future<void> _cargarCliente(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('clientes')
          .doc(uid)
          .get();
      if (doc.exists) {
        _clienteActual = ClienteModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      // Cliente no encontrado o error de red
    }
  }

  Future<bool> login(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final credencial = await _authService.loginConCorreo(email, password);
      if (credencial?.user != null) {
        _usuario = credencial!.user;
        await _cargarCliente(_usuario!.uid);
        _cargando = false;
        notifyListeners();
        return true;
      }
      _cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrar(String email, String password, String nombre) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final credencial =
          await _authService.registrarConCorreo(email, password, nombre);
      if (credencial?.user != null) {
        _usuario = credencial!.user;
        await _cargarCliente(_usuario!.uid);
        _cargando = false;
        notifyListeners();
        return true;
      }
      _cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginGoogle() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final credencial = await _authService.loginConGoogle();
      if (credencial?.user != null) {
        _usuario = credencial!.user;
        await _cargarCliente(_usuario!.uid);
        _cargando = false;
        notifyListeners();
        return true;
      }
      _cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.cerrarSesion();
    _usuario = null;
    _clienteActual = null;
    notifyListeners();
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  Future<void> recuperarPassword(String email) async {
    try {
      await _authService.recuperarPassword(email);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
