import 'package:flutter/material.dart';
import '../models/envio_model.dart';
import '../services/delivery_service.dart';

class DeliveryProvider extends ChangeNotifier {
  final DeliveryService _deliveryService = DeliveryService();

  List<EnvioModel> _envios = [];
  bool _cargando = false;
  String? _error;

  List<EnvioModel> get envios => _envios;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarEnvios(String conductorId) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _envios = await _deliveryService.obtenerEnviosPorConductor(conductorId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
