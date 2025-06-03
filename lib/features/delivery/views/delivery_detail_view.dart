import 'package:flutter/material.dart';
import '../models/envio_model.dart';

class DeliveryDetailView extends StatelessWidget {
  final EnvioModel envio;

  const DeliveryDetailView({Key? key, required this.envio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Envío')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text('ID Envío: ${envio.idEnvio}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Estado actual: ${envio.estadoActual}'),
            SizedBox(height: 10),
            Text('Fecha último estado: ${envio.fechaUltimoEstado ?? "No disponible"}'),
            SizedBox(height: 10),
            Text('Remitente (ID): ${envio.remitente}'),
            SizedBox(height: 10),
            Text('Receptor (ID): ${envio.receptor}'),
            SizedBox(height: 10),
            Text('Ruta (ID): ${envio.rutaId}'),
            SizedBox(height: 10),
            // Los campos siguientes aparecerán solo si el backend los empieza a enviar
            Text('Dirección: ${envio.direccion ?? "No disponible"}'),
            SizedBox(height: 10),
            Text('Contacto: ${envio.contacto ?? "No disponible"}'),
            SizedBox(height: 10),
            Text('Instrucciones: ${envio.instrucciones ?? "No disponible"}'),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // lógica para confirmar entrega aquí
              },
              icon: Icon(Icons.check_circle),
              label: Text('Confirmar Entrega'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // lógica para abrir mapa aquí
              },
              icon: Icon(Icons.map),
              label: Text('Abrir Mapa'),
            ),
          ],
        ),
      ),
    );
  }
}
