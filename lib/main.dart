import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:frontend/features/delivery/views/delivery_list_view.dart';
import 'package:frontend/features/maps/providers/map_provider.dart';
import 'package:frontend/features/maps/views/openstreetmap_view.dart';
import 'package:frontend/features/orders/views/orders_home_view.dart';
import 'package:frontend/features/profile/screens/profile_screen.dart';
import 'package:frontend/shared/test_connection_screen.dart';

import 'features/auth/views/login_screen.dart';
import 'features/auth/views/welcome_screen.dart';
import 'features/auth/services/auth_service.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cliente App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // <- Pantalla que decide dónde ir
      routes: {
        '/home': (context) => const HomeScreen(),
        '/map': (context) => const OpenStreetMapView(),
        '/test': (context) => TestConnectionScreen(),
        '/login': (context) => LoginScreen(),
        '/welcome': (context) =>  WelcomeScreen(),
        '/orders': (context) => const OrdersHomeView(), // Pantalla para el menu de ordenes
        '/delivery': (context) => DeliveryListView(),
        '/profile': (context) {
          final rutCliente = ModalRoute.of(context)!.settings.arguments as String;
          return ProfileScreen(rutCliente: rutCliente);
        },
      },
    );
  }
}
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String?> _getRutCliente() async {
    // TODO: Implementar autenticación real
    // Por ahora, retornamos un RUT de prueba
    // Este RUT debe existir en la base de datos para que funcione correctamente
    return '21.595.452-3'; // RUT de prueba - Reemplazar con el RUT de un cliente existente en la base de datos

    // Código original que se usará cuando se implemente la autenticación:
    // const storage = FlutterSecureStorage();
    // return await storage.read(key: 'rut_cliente');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú de Navegación')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/map');
              },
              child: const Text('Ir al Mapa'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/test');
              },
              child: const Text('Probar conexión Backend'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1));
    final isLoggedIn = await AuthService.isLoggedIn(); // <- Revisa sesión

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_taxi, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Cliente App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/orders');
              },
              child: const Text('Ordenes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/delivery');
              },
              child: const Text('Delivery'),
            ),
            ElevatedButton(
              onPressed: () async {
                final rutCliente = await _getRutCliente();
                if (rutCliente != null) {
                  Navigator.pushNamed(
                    context,
                    '/profile',
                    arguments: rutCliente,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se encontró el RUT del cliente'),
                    ),
                  );
                }
              },
              child: const Text('Mi Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
