// screens/test_connection_screen.dart
import 'package:flutter/material.dart';
import '../core/services/test_service.dart';

/// Pantalla para probar la conexión con el backend
///
/// Esta pantalla realiza las siguientes funciones:
/// 1. Muestra un mensaje inicial de "Verificando conexión..."
/// 2. Intenta conectarse al backend usando TestService
/// 3. Muestra el resultado de la conexión (éxito o error)
class TestConnectionScreen extends StatefulWidget {
  @override
  _TestConnectionScreenState createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  /// Mensaje que se muestra en la pantalla
  /// Inicialmente muestra "Verificando conexión..."
  /// Se actualiza con el resultado de la prueba de conexión
  String message = 'Verificando conexión...';

  @override
  void initState() {
    super.initState();
    // Al iniciar la pantalla, se ejecuta la prueba de conexión
    _checkConnection();
  }

  /// Método que prueba la conexión con el backend
  ///
  /// El flujo es el siguiente:
  /// 1. Llama a TestService para verificar la conexión
  /// 2. Espera la respuesta (éxito o error)
  /// 3. Actualiza el mensaje en la pantalla con el resultado
  void _checkConnection() async {
    final result = await TestService().testConnection();
    setState(() {
      message = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con el título de la pantalla
      appBar: AppBar(title: Text('Test Conexión')),

      // Cuerpo de la pantalla que muestra el mensaje centrado
      body: Center(child: Text(message, style: TextStyle(fontSize: 20))),
    );
  }
}
