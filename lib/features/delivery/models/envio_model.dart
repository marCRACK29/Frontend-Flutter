class EnvioModel {
  final int id;
  final String remitenteId;
  final String? receptorId;
  final String conductorId;
  final int? rutaId;
  final String direccionOrigen;
  final String direccionDestino;
  final String estado;

  EnvioModel({
    required this.id,
    required this.remitenteId,
    this.receptorId,
    required this.conductorId,
    this.rutaId,
    required this.direccionOrigen,
    required this.direccionDestino,
    required this.estado,
  });

  // Factory constructor para crear desde respuesta del backend
  factory EnvioModel.fromBackendResponse(Map<String, dynamic> json) {
    return EnvioModel(
      id: _parseToInt(json['id']),
      remitenteId: _parseToString(json['remitente_id']),
      receptorId: json['receptor_id'] != null ? _parseToString(json['receptor_id']) : null,
      conductorId: _parseToString(json['conductor_id']),
      rutaId: json['ruta_id'] != null ? _parseToInt(json['ruta_id']) : null,
      direccionOrigen: _parseToString(json['direccion_origen']),
      direccionDestino: _parseToString(json['direccion_destino']),
      estado: json['estado_actual']?['estado'] != null 
          ? _parseToString(json['estado_actual']['estado']) 
          : 'Sin estado',
    );
  }

  // Métodos auxiliares para conversión segura de tipos
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  static String _parseToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }

  // Método para debug - opcional
  @override
  String toString() {
    return 'EnvioModel{id: $id, remitenteId: $remitenteId, receptorId: $receptorId, conductorId: $conductorId, rutaId: $rutaId, direccionOrigen: $direccionOrigen, direccionDestino: $direccionDestino, estado: $estado}';
  }
}