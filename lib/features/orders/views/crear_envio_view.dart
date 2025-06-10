import 'package:flutter/material.dart';
import '../models/envio_model.dart';
import '../services/envio_service.dart';
import 'package:frontend/features/auth/services/auth_service.dart';

class CrearEnvioScreen extends StatefulWidget {
  const CrearEnvioScreen({super.key});

  @override
  State<CrearEnvioScreen> createState() => _CrearEnvioScreenState();
}

class _CrearEnvioScreenState extends State<CrearEnvioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receptorController = TextEditingController();
  final _origenController = TextEditingController();
  final _destinoController = TextEditingController();

  final EnvioService envioService = EnvioService();
  String? remitenteId;
   final String conductorId = "15.123.102-4";
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await AuthService.getUserInfo();
    setState(() {
      remitenteId = userInfo['id'];
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final envio = Envio(
          remitenteId: remitenteId!,
          receptorId: _receptorController.text,
          conductorId: conductorId,
          direccionOrigen: _origenController.text,
          direccionDestino: _destinoController.text,
        );

        final respuesta = await envioService.crearEnvio(envio);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Envío creado: ID ${respuesta["envío"]["id"]}')),
        );
        Navigator.pop(context); // Regresa a la pantalla anterior después de crear el envío
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
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: const Text(
          "Crear nuevo envío",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (remitenteId != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Remitente: $remitenteId',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              TextFormField(
                controller: _receptorController,
                decoration: const InputDecoration(labelText: "Receptor ID"),
                validator: (value) => value == null || value.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _origenController,
                decoration: const InputDecoration(labelText: "Dirección de Origen"),
                validator: (value) => value == null || value.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _destinoController,
                decoration: const InputDecoration(labelText: "Dirección de Destino"),
                validator: (value) => value == null || value.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Enviar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _receptorController.dispose();
    _origenController.dispose();
    _destinoController.dispose();
    super.dispose();
  }
}
