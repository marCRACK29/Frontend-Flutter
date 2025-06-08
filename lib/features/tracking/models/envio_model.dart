class Envio {
  final int id;
  final String remitenteId;
  final String? receptorId;
  final String conductorId;
  final String direccionOrigen;
  final String direccionDestino;
  final EstadoEntrega? estadoActual;

  Envio({
    required this.id,
    required this.remitenteId,
    this.receptorId,
    required this.conductorId,
    required this.direccionOrigen,
    required this.direccionDestino,
    this.estadoActual,
  });

  factory Envio.fromJson(Map<String, dynamic> json) {
    return Envio(
      id: json['id_envio'] ?? 0,
      remitenteId: json['remitente_id'] ?? '',
      receptorId: json['receptor_id'],
      conductorId: json['conductor_id'] ?? '',
      direccionOrigen: json['direccion_origen'] ?? '',
      direccionDestino: json['direccion_destino'] ?? '',
      estadoActual: json['estado_actual'] != null 
          ? EstadoEntrega.fromJson(json['estado_actual']) 
          : null,
    );
  }
}

class EstadoEntrega {
  final int id;
  final String nombre;
  final String descripcion;

  EstadoEntrega({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory EstadoEntrega.fromJson(Map<String, dynamic> json) {
    return EstadoEntrega(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }
}
