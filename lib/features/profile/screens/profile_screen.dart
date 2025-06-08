import 'package:flutter/material.dart';
import '../services/cliente_service.dart';
import '../models/cliente_model.dart';

class ProfileScreen extends StatefulWidget {
  final String rutCliente;

  const ProfileScreen({Key? key, required this.rutCliente}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ClienteService _clienteService = ClienteService();
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  Cliente? _cliente;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatosCliente();
  }

  Future<void> _cargarDatosCliente() async {
    try {
      final cliente = await _clienteService.obtenerInfoCliente(widget.rutCliente);
      setState(() {
        _cliente = cliente;
        _correoController.text = cliente.correo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _actualizarCorreo() async {
    if (_formKey.currentState!.validate()) {
      try {
        final clienteActualizado = await _clienteService.actualizarCorreo(
          widget.rutCliente,
          _correoController.text,
        );
        setState(() {
          _cliente = clienteActualizado;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo actualizado exitosamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el correo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: $_error'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información Personal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Personal',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('RUT', _cliente!.rut),
                    _buildInfoRow('Nombre', _cliente!.nombre),
                    _buildInfoRow('Correo', _cliente!.correo),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Formulario de Actualización de Correo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actualizar Correo Electrónico',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _correoController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Ingrese su nuevo correo electrónico',
                              labelText: 'Nuevo Correo Electrónico',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese un correo';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Ingrese un correo válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _actualizarCorreo,
                              child: const Text('Actualizar Correo'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }
} 