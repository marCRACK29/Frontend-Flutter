import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:frontend/features/maps/providers/map_provider.dart';
import 'package:frontend/features/maps/views/openstreetmap_view.dart';
import 'package:frontend/shared/test_connection_screen.dart';

import 'features/auth/views/login_screen.dart';
import 'features/auth/views/welcome_screen.dart';
import 'features/auth/views/profile_screen.dart';
import 'features/auth/services/auth_service.dart'; 

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
          ],
        ),
      ),
    );
  }
}
