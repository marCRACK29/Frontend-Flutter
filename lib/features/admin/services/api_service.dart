import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';



class ApiService {

  static String get baseUrl => dotenv.env['API_URL']!;
  Future<List> getEnviosSinConductor() async {
    final response = await http.get(
    Uri.parse('$baseUrl/api/admin/envios_sin_conductor'),
    headers: {
      "Ngrok-Skip-Browser-Warning": "1",
    },
  );
    final data = json.decode(response.body);
    return data['envios'];
  }

  Future<List> getConductores() async {
    final response = await http.get(
    Uri.parse('$baseUrl/api/admin/conductores'),
    headers: {
      "Ngrok-Skip-Browser-Warning": "1",
    },
  );
    final data = json.decode(response.body);
    return data['conductores'];
  }

  Future<bool> asignarConductor(int envioId, String rutConductor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/admin/asignar_conductor/$envioId'),
      headers: {"Content-Type": "application/json", "Ngrok-Skip-Browser-Warning": "1",},
      body: json.encode({"rut_conductor": rutConductor}),
    );
    return response.statusCode == 200;
  }
}
