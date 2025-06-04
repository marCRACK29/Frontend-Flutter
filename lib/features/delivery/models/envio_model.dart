import 'estado_model.dart';

class EnvioModel {
  final int idEnvio;
  final EstadoModel estadoActual;
  final String direccionDestino;
  final String remitente;
  final String? receptor;
  final String conductorId;

  EnvioModel({
    required this.idEnvio,
    required this.estadoActual,
    required this.direccionDestino,
    required this.remitente,
    this.receptor,
    required this.conductorId,
  });

  factory EnvioModel.fromJson(Map<String, dynamic> json) {
    return EnvioModel(
      idEnvio: json['id_envio'],
      estadoActual: EstadoModel.fromJson(json['estado_actual']),
      direccionDestino: json['direccion_destino'],
      remitente: json['remitente'],
      receptor: json['receptor'],
      conductorId: json['conductor_id'],
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> origin/delivery
