import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/cliente/producto_detalle_screen.dart';
import '../screens/cliente/checkout_screen.dart';
import '../screens/cliente/pedido_exitoso_screen.dart';
import '../screens/cliente/categoria_screen.dart';
import '../screens/admin/admin_panel_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final path = state.matchedLocation;

    final rutasProtegidas = ['/home', '/checkout', '/admin'];
    final isProtegida = rutasProtegidas.any((r) => path.startsWith(r));

    if (!loggedIn && isProtegida) return '/login';
    if (loggedIn && path == '/login') return '/home';

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/producto/:id',
      builder: (context, state) => ProductoDetalleScreen(
        productoId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/pedido-exitoso/:pedidoId',
      builder: (context, state) => PedidoExitosoScreen(
        pedidoId: state.pathParameters['pedidoId'] ?? '',
        metodoPago: state.uri.queryParameters['metodo'] ?? 'Tarjeta',
      ),
    ),
    GoRoute(
      path: '/categoria/:id',
      builder: (context, state) => CategoriaScreen(
        categoriaId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) {
        final email = FirebaseAuth.instance.currentUser?.email ?? '';
        final esAdmin = email.endsWith('@admin.com');
        return esAdmin
            ? const AdminPanelScreen()
            : const HomeScreen();
      },
    ),
  ],
);
