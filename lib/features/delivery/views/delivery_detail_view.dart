import 'package:flutter/material.dart';
import '../models/envio_model.dart';
import '../services/delivery_service.dart';

class DeliveryDetailView extends StatefulWidget {
  final EnvioModel envio;

  const DeliveryDetailView({Key? key, required this.envio}) : super(key: key);

  @override
  State<DeliveryDetailView> createState() => _DeliveryDetailViewState();
}

class _DeliveryDetailViewState extends State<DeliveryDetailView> {
  late String _estadoActual;

  @override
  void initState() {
    super.initState();
    _estadoActual = widget.envio.estadoActual.estado;
  }

  Future<void> _actualizarEstado(String nuevoEstado) async {
    try {
      await DeliveryService().actualizarEstadoEnvio(widget.envio.idEnvio, nuevoEstado);
      setState(() {
        _estadoActual = nuevoEstado;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a "$nuevoEstado"')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar estado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final envio = widget.envio;
    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Envío')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text('ID Envío: ${envio.idEnvio}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Estado actual: $_estadoActual'),
            SizedBox(height: 10),
            Text('Dirección de destino: ${envio.direccionDestino}'),
            SizedBox(height: 10),
            Text('Remitente: ${envio.remitente}'),
            SizedBox(height: 10),
            Text('Receptor: ${envio.receptor ?? "No disponible"}'),
            SizedBox(height: 10),
            Text('Conductor ID: ${envio.conductorId}'),
            SizedBox(height: 30),
            Text('Cambiar estado:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _actualizarEstado("preparacion"),
                    child: Text('En preparación'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _actualizarEstado("transito"),
                    child: Text('En camino'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _actualizarEstado("entregado"),
                    child: Text('Entregado'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
