import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/envio_model.dart';

class EnvioService {
  static String get baseUrl => dotenv.env['API_URL'] ?? 'http://localhost:5000';

  static Future<List<Envio>> getEnviosByConductor(String conductorId) async {
    try {
      final url = '$baseUrl/api/envios/conductor?conductor_id=$conductorId';
      print('🌐 Haciendo petición a: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          },
      );
      print('📥 Status code: ${response.statusCode}');
      // print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Envio.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching envios: $e');
      return [];
    }
  }

  static Future<Envio?> getEnvioById(int envioId) async {
    try {
      final url = '$baseUrl/api/envios/$envioId';
      print('🌐 Haciendo petición a: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
      );
      print('📥 Status code: ${response.statusCode}');
      // print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Envio.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching envio: $e');
      return null;
    }
  }
}
