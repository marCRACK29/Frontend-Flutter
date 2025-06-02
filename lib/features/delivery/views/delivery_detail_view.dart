import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/envio_model.dart';
import '../services/delivery_service.dart';
import '../../maps/views/openstreetmap_view.dart';

class DeliveryDetailView extends StatefulWidget {
  final EnvioModel envio;

  const DeliveryDetailView({super.key, required this.envio});

  @override
  State<DeliveryDetailView> createState() => _DeliveryDetailViewState();
}

class _DeliveryDetailViewState extends State<DeliveryDetailView> {
  final DeliveryService _deliveryService = DeliveryService();

  String? _estadoActual;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _estadoActual = widget.envio.estado;
  }

  void _confirmarEntrega() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar entrega'),
        content: const Text('¿Estás seguro de marcar este envío como "Entregado"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    setState(() => _cargando = true);

    try {
      await _deliveryService.actualizarEstadoEnvio(widget.envio.id, 'Entregado');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrega confirmada')),
      );

      setState(() {
        _estadoActual = 'Entregado';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar: $e')),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OpenStreetMapView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final envio = widget.envio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Envío'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dirección:', style: Theme.of(context).textTheme.titleMedium),
            Text(envio.direccion),
            const SizedBox(height: 12),

            Text('Contacto:', style: Theme.of(context).textTheme.titleMedium),
            Text(envio.contacto),
            const SizedBox(height: 12),

            Text('Instrucciones:', style: Theme.of(context).textTheme.titleMedium),
            Text(envio.instrucciones),
            const SizedBox(height: 12),

            Text('Estado actual: $_estadoActual',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirmar Entrega'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: _cargando ? null : _confirmarEntrega,
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Abrir Mapa'),
                onPressed: _abrirMapa,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
