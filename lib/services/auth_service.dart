import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get usuarioActual => _auth.currentUser;
  Stream<User?> get estadoAuth => _auth.authStateChanges();

  Future<UserCredential?> loginConCorreo(String email, String password) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credencial;
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        mensaje = 'No existe una cuenta con este correo';
      } else if (e.code == 'wrong-password') {
        mensaje = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-credential') {
        mensaje = 'Correo o contraseña incorrectos';
      } else if (e.code == 'too-many-requests') {
        mensaje = 'Demasiados intentos. Intenta más tarde';
      }
      throw Exception(mensaje);
    }
  }

  Future<UserCredential?> registrarConCorreo(
    String email,
    String password,
    String nombre,
  ) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credencial.user;
      if (user != null) {
        await user.updateDisplayName(nombre);
        await _firestore.collection('clientes').doc(user.uid).set({
          'nombre': nombre,
          'email': email,
          'telefono': '',
          'fechaNacimiento': '',
          'avatarUrl': '',
          'favoritos': [],
          'esAdmin': false,
        });
      }
      return credencial;
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al registrarse';
      if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya está registrado';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña debe tener al menos 6 caracteres';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo no es válido';
      }
      throw Exception(mensaje);
    }
  }

  Future<UserCredential?> loginConGoogle() async {
    try {
      // En web usar signInWithPopup
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        final credencial = await _auth.signInWithPopup(googleProvider);
        final user = credencial.user;
        if (user != null && credencial.additionalUserInfo?.isNewUser == true) {
          await _firestore.collection('clientes').doc(user.uid).set({
            'nombre': user.displayName ?? '',
            'email': user.email ?? '',
            'telefono': '',
            'fechaNacimiento': '',
            'avatarUrl': user.photoURL ?? '',
            'favoritos': [],
            'esAdmin': false,
          });
        }
        return credencial;
      }

      // En móvil usar GoogleSignIn normal
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final credencial = await _auth.signInWithCredential(credential);
      final user = credencial.user;
      if (user != null && credencial.additionalUserInfo?.isNewUser == true) {
        await _firestore.collection('clientes').doc(user.uid).set({
          'nombre': user.displayName ?? '',
          'email': user.email ?? '',
          'telefono': '',
          'fechaNacimiento': '',
          'avatarUrl': user.photoURL ?? '',
          'favoritos': [],
          'esAdmin': false,
        });
      }
      return credencial;
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al iniciar sesión con Google';
      if (e.code == 'account-exists-with-different-credential') {
        mensaje = 'Ya existe una cuenta con este correo usando otro método';
      }
      throw Exception(mensaje);
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google');
    }
  }

  Future<void> recuperarPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al enviar correo de recuperación';
      if (e.code == 'user-not-found') {
        mensaje = 'No existe una cuenta con este correo';
      }
      throw Exception(mensaje);
    }
  }

  Future<void> cerrarSesion() async {
    try {
      // Solo cerrar Google si no estamos en web y si está conectado
      if (!kIsWeb) {
        final isSignedIn = await _googleSignIn.isSignedIn();
        if (isSignedIn) {
          await _googleSignIn.signOut();
        }
      }
    } catch (e) {
      debugPrint('Google sign out error: $e');
    }
    await _auth.signOut();
  }
}
