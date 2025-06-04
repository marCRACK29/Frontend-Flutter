import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/maps/providers/map_provider.dart';
import 'package:frontend/features/maps/views/openstreetmap_view.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/test_connection_screen.dart';
import 'features/delivery/views/delivery_list_view.dart';
import 'package:frontend/features/tracking/services/tracking_service.dart';
import 'features/tracking/views/tracking_screen.dart';
import 'package:frontend/features/orders/views/orders_home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // carga las variables de entorno
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => TrackingService()),
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
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/map': (context) => const OpenStreetMapView(),
        '/test': (context) => TestConnectionScreen(),
        '/tracking':
            (context) => const TrackingScreen(
              envioId: 4,
              userType: 'cliente',
              userId: '21.595.452-3',
            ),
        '/delivery': (context) => DeliveryListView(),
        '/orders': (context) => const OrdersHomeView(), // Pantalla para el menu de ordenes
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
                Navigator.pushReplacementNamed(context, '/tracking');
              },
              child: const Text('Monitoreo de envíos'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/delivery');
              },
              child: const Text('Gestión de Entregas'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/orders');
              },
              child: const Text('Ordenes'),
            ),
          ],
        ),
      ),
    );
  }
}
