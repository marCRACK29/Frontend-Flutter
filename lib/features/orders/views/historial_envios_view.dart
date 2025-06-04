import 'package:flutter/material.dart';

class HistorialEnviosView extends StatelessWidget {
  final List<dynamic> envios;

  const HistorialEnviosView({super.key, required this.envios});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: const Text(
          'Historial de Envíos',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: envios.length,
        itemBuilder: (context, index) {
          final envio = envios[index];

          // Asegurar que el estado_actual es un Map antes de acceder
          final estado = envio['estado_actual'];
          final estadoTexto = estado != null && estado is Map<String, dynamic>
              ? estado['estado'] ?? 'Sin estado'
              : 'Sin estado';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('Envío #${envio['id_envio']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado: $estadoTexto'),
                  Text('Destinatario: ${envio['receptor_id']}'),
                  Text('Dirección: ${envio['direccion_destino'] ?? 'No especificada'}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
