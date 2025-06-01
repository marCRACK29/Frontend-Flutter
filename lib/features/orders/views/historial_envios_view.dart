import 'package:flutter/material.dart';

class HistorialEnviosView extends StatelessWidget {
  final List<dynamic> envios;

  const HistorialEnviosView({super.key, required this.envios});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Envíos')),
      body: ListView.builder(
        itemCount: envios.length,
        itemBuilder: (context, index) {
          final envio = envios[index];
          return ListTile(
            title: Text('Envío #${envio['id_envio']}'),
            subtitle: Text(
                'Estado: ${envio['estado_actual']} - Fecha: ${envio['fecha_ultimo_estado']}'),
          );
        },
      ),
    );
  }
}
