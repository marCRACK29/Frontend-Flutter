class EnvioModel {
  final int idEnvio;
  final String estadoActual;
  final String? fechaUltimoEstado;
  final String remitente;
  final String receptor;
  final String rutaId;

  // Los campos opcionales para el futuro
  final String? direccion;
  final String? contacto;
  final String? instrucciones;
  final double? lat;
  final double? lng;

  EnvioModel({
    required this.idEnvio,
    required this.estadoActual,
    this.fechaUltimoEstado,
    required this.remitente,
    required this.receptor,
    required this.rutaId,
    this.direccion,
    this.contacto,
    this.instrucciones,
    this.lat,
    this.lng,
  });

  factory EnvioModel.fromJson(Map<String, dynamic> json) {
    return EnvioModel(
      idEnvio: json['id_envio'],
      estadoActual: json['estado_actual'] ?? '',
      fechaUltimoEstado: json['fecha_ultimo_estado'],
      remitente: json['remitente']?.toString() ?? '',
      receptor: json['receptor']?.toString() ?? '',
      rutaId: json['ruta_id']?.toString() ?? '',
      direccion: json['direccion'],          // Para futuro, si lo agregas al backend
      contacto: json['contacto'],           // Para futuro, si lo agregas al backend
      instrucciones: json['instrucciones'], // Para futuro
      lat: json['lat']?.toDouble(),         // Para futuro
      lng: json['lng']?.toDouble(),         // Para futuro
    );
  }
}

