import 'package:flutter/material.dart';
import 'package:frontend/features/orders/services/envio_service.dart';
import 'package:frontend/features/orders/views/crear_envio_view.dart';
import 'package:frontend/features/orders/views/historial_envios_view.dart';


class OrdersHomeView extends StatefulWidget {
  const OrdersHomeView({super.key});

  @override
  State<OrdersHomeView> createState() => _OrdersHomeViewState();
}

class _OrdersHomeViewState extends State<OrdersHomeView> {
  final envioService = EnvioService();

  Future<void> _verHistorial() async {
  try {
    String usuarioId = '21.595.452-3'; // Reemplaza con el usuario logueado
    final envios = await envioService.obtenerEnviosPorUsuario(usuarioId);
    if (!mounted) return; // Verifica que el widget esté montado

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
