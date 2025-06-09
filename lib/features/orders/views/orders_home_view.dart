import 'package:flutter/material.dart';
import 'package:frontend/features/orders/services/envio_service.dart';
import 'package:frontend/features/orders/views/crear_envio_view.dart';
import 'package:frontend/features/orders/views/historial_envios_view.dart';
import 'package:frontend/features/auth/services/auth_service.dart';

class OrdersHomeView extends StatefulWidget {
  const OrdersHomeView({super.key});

  @override
  State<OrdersHomeView> createState() => _OrdersHomeViewState();
}

class _OrdersHomeViewState extends State<OrdersHomeView> {
  final envioService = EnvioService();

  Future<void> _verHistorial() async {
    try {
      final userInfo = await AuthService.getUserInfo();
      final usuarioId = userInfo['id'];
      
      if (usuarioId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el RUT del usuario')),
        );
        return;
      }

      final envios = await envioService.obtenerEnviosPorUsuario(usuarioId);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HistorialEnviosView(envios: envios),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: const Text(
          "Envíos",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _verHistorial,
              child: const Text("Ver historial de envíos"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CrearEnvioScreen()),
                );
              },
              child: const Text("Crear nuevo envío"),
            ),
          ],
        ),
      ),
    );
  }
}
