// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _rutController = TextEditingController();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _numeroDomicilioController = TextEditingController();
  final _calleController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _regionController = TextEditingController();
  final _codigoPostalController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_rutController.text.isEmpty ||
        _nombreController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _contrasenaController.text.isEmpty ||
        _numeroDomicilioController.text.isEmpty ||
        _calleController.text.isEmpty ||
        _ciudadController.text.isEmpty ||
        _regionController.text.isEmpty ||
        _codigoPostalController.text.isEmpty) {
      _showMessage('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.registrarCliente(
      rut: _rutController.text.trim(),
      nombre: _nombreController.text.trim(),
      correo: _correoController.text.trim(),
      contrasena: _contrasenaController.text,
      numeroDomicilio: int.parse(_numeroDomicilioController.text),
      calle: _calleController.text.trim(),
      ciudad: _ciudadController.text.trim(),
      region: _regionController.text.trim(),
      codigoPostal: int.parse(_codigoPostalController.text),
    );

    setState(() => _isLoading = false);

    _showMessage(result['message']);

    if (result['success']) {
      Navigator.pop(context); // Volver al login
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrarse'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 60,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _rutController,
              decoration: InputDecoration(
                labelText: 'RUT',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _correoController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),
            TextField(
              controller: _contrasenaController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 15),
            TextField(
              controller: _numeroDomicilioController,
              decoration: InputDecoration(
                labelText: 'Número domicilio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 15),
            TextField(
              controller: _calleController,
              decoration: InputDecoration(
                labelText: 'Calle',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _ciudadController,
              decoration: InputDecoration(
                labelText: 'Ciudad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _regionController,
              decoration: InputDecoration(
                labelText: 'Región',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _codigoPostalController,
              decoration: InputDecoration(
                labelText: 'Código postal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_post_office),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Registrarse',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rutController.dispose();
    _nombreController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _numeroDomicilioController.dispose();
    _calleController.dispose();
    _ciudadController.dispose();
    _regionController.dispose();
    _codigoPostalController.dispose();
    super.dispose();
  }
}