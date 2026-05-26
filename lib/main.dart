import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'config/firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/catalogo_provider.dart';
import 'providers/carrito_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/cliente/producto_detalle_screen.dart';
import 'screens/cliente/checkout_screen.dart';
import 'screens/cliente/pedido_exitoso_screen.dart';
import 'screens/cliente/categoria_screen.dart';
import 'screens/admin/admin_panel_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DivineBeautyApp());
}

class DivineBeautyApp extends StatelessWidget {
  const DivineBeautyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..inicializar()),
        ChangeNotifierProvider(create: (_) => CatalogoProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
      ],
      child: MaterialApp(
        title: 'Divine Beauty',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('es', 'MX'),
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin': (context) => const AdminPanelScreen(),
          '/checkout': (context) => const CheckoutScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/producto') {
            final id = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => ProductoDetalleScreen(productoId: id),
            );
          }
          if (settings.name == '/pedido-exitoso') {
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (_) => PedidoExitosoScreen(
                pedidoId: args['pedidoId'] ?? '',
                metodoPago: args['metodo'] ?? 'Tarjeta',
              ),
            );
          }
          if (settings.name == '/categoria') {
            final id = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => CategoriaScreen(categoriaId: id),
            );
          }
          return null;
        },
      ),
    );
  }
}
