import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/maps/providers/map_provider.dart';
import 'package:frontend/features/maps/views/openstreetmap_view.dart';
import 'features/auth/views/login_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/delivery/views/delivery_list_view.dart';
import 'package:frontend/features/orders/views/orders_home_view.dart';
import 'package:frontend/features/tracking/views/conductor_tracking_screen.dart';
import 'package:frontend/features/profile/screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MapProvider())],
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
      home: const SplashScreen(),
      routes: { // Cada uno representa un distinto "feature"
        '/home': (context) => const HomeScreen(), // Home que decide si mostrar perfil de cliente o conductor
        '/map': (context) => const OpenStreetMapView(), // Pantalla que proporciona el mapa con el buscador
        '/login': (context) => LoginScreen(), // Pantalla para logearse (por el momento solo para clientes nuevos)
        '/orders': (context) => const OrdersHomeView(), // Pantalla para el menu de ordenes
        '/tracking': (context) => ConductorTrackingScreen(conductorId: '15.123.102-4'), // Mapa que muestra la ruta de un envío (para conductore)
        '/delivery': (context) => DeliveryListView(), // Pantalla que permite modificar el estado de los envíos
        '/profile': (context) { // Pantalla para el perfíl de un cliente ya registrado
          final rutCliente =
              ModalRoute.of(context)!.settings.arguments as String;
          return ProfileScreen(rutCliente: rutCliente);
        },
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú de Navegación')),
      body: FutureBuilder<Map<String, String?>>(
        future: AuthService.getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Error al cargar la información del usuario'),
            );
          }

          final userInfo = snapshot.data!;
          final userType = userInfo['tipo'];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (userType == 'cliente') ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/orders');
                    },
                    child: const Text('Órdenes'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final rutCliente = userInfo['id'];
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
                ] else if (userType == 'conductor') ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/delivery');
                    },
                    child: const Text('Estados de mis envíos'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/tracking');
                    },
                    child: const Text('Ruta de mis envíos'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/map');
                    },
                    child: const Text('Ir al Mapa'),
                  ),
                ],
                // Botones comunes para ambos tipos de usuario
                ElevatedButton(
                  onPressed: () async {
                    await AuthService.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          );
        },
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
    final isLoggedIn = await AuthService.isLoggedIn(); // Revisa sesión

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
              'PaquiMóvil', // Nombre de nuestra app
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
