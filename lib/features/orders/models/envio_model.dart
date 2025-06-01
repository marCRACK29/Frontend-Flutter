class Envio {
  final String remitenteId;
  final int rutaId;
  final String conductorId;
  final List<Paquete> paquetes;

  Envio({
    required this.remitenteId,
    required this.rutaId,
    required this.conductorId,
    required this.paquetes,
  });

  Map<String, dynamic> toJson() {
    return {
      "remitente_id": remitenteId,
      "ruta_id": rutaId,
      "conductor_id": conductorId,
      "paquetes": paquetes.map((p) => p.toJson()).toList(),
    };
  }
}

class Paquete {
  final int peso;
  final int? alto;
  final int? largo;
  final int? ancho;
  final String? descripcion;

  Paquete({
    required this.peso,
    this.alto,
    this.largo,
    this.ancho,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      "peso": peso,
      "alto": alto,
      "largo": largo,
      "ancho": ancho,
      "descripcion": descripcion,
    };
  }
}
