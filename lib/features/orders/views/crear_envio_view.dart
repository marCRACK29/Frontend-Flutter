import 'package:flutter/material.dart';
import '../models/envio_model.dart';
import '../services/envio_service.dart';

class CrearEnvioScreen extends StatefulWidget {
  const CrearEnvioScreen({super.key});

  @override
  State<CrearEnvioScreen> createState() => _CrearEnvioScreenState();
}

class _CrearEnvioScreenState extends State<CrearEnvioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _remitenteController = TextEditingController();
  final _conductorController = TextEditingController();
  final _rutaController = TextEditingController();
  final _pesoController = TextEditingController();

  final EnvioService envioService = EnvioService();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final envio = Envio(
          remitenteId: _remitenteController.text,
          rutaId: int.parse(_rutaController.text),
          conductorId: _conductorController.text,
          paquetes: [
            Paquete(
              peso: int.parse(_pesoController.text),
            )
          ],
        );

        final respuesta = await envioService.crearEnvio(envio);
        print('Respuesta completa: $respuesta');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Envío creado: ID ${respuesta["envio"]["id"]}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear nuevo envío")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _remitenteController, decoration: const InputDecoration(labelText: "Remitente ID")),
              TextFormField(controller: _conductorController, decoration: const InputDecoration(labelText: "Conductor ID")),
              TextFormField(controller: _rutaController, decoration: const InputDecoration(labelText: "Ruta ID")),
              TextFormField(controller: _pesoController, decoration: const InputDecoration(labelText: "Peso del paquete")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text("Enviar")),
            ],
          ),
        ),
      ),
    );
  }
}
