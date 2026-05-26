import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalogo_provider.dart';
import '../../config/app_theme.dart';
import '../admin/admin_panel_screen.dart';
import 'home_tab.dart';
import '../cliente/novedades_screen.dart';
import '../cliente/carrito_screen.dart';
import '../cliente/yo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogoProvider>().inicializar();
    });
  }

  bool _esAdmin(AuthProvider auth) {
    final email = auth.usuario?.email ?? '';
    if (email.endsWith('@admin.com')) return true;
    return auth.clienteActual?.esAdmin ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final admin = _esAdmin(auth);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            title: const Text('Divine Beauty',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: admin
                ? [
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings,
                          color: Colors.white),
                      tooltip: 'Panel Admin',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminPanelScreen()),
                      ),
                    ),
                  ]
                : null,
          ),
          body: IndexedStack(
            index: _tabIndex,
            children: const [
              HomeTab(),
              NovedadesScreen(),
              CarritoScreen(),
              YoScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _tabIndex,
            selectedItemColor: AppTheme.accentColor,
            unselectedItemColor: const Color(0xFFBBBBBB),
            backgroundColor: Colors.white,
            elevation: 8,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            onTap: (i) => setState(() => _tabIndex = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_outlined),
                activeIcon: Icon(Icons.auto_awesome),
                label: 'Novedades',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Carrito',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Yo',
              ),
            ],
          ),
        );
      },
    );
  }
}
