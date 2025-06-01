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
    String usuarioId = '15.123.123-4'; // Reemplaza con el usuario logueado
    final envios = await envioService.obtenerEnviosPorUsuario(usuarioId);

    if (!mounted) return; // Verifica que el widget esté montado

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistorialEnviosView(envios: envios),
      ),
    );
  } catch (e) {
    print("Error al obtener historial: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Órdenes")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _verHistorial,
              child: const Text("Ver historial de órdenes"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CrearEnvioScreen()),
                );
              },
              child: const Text("Crear nueva orden"),
            ),
          ],
        ),
      ),
    );
  }
}
