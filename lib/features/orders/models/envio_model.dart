class Envio {
  final String remitenteId;
  final String receptorId;
  final String direccionOrigen;
  final String direccionDestino;

  Envio({
    required this.remitenteId,
    required this.receptorId,
    required this.direccionOrigen,
    required this.direccionDestino,
  });

  Map<String, dynamic> toJson() {
    return {
      "remitente_id": remitenteId,
      "receptor_id": receptorId,
      "direccion_origen": direccionOrigen,
      "direccion_destino": direccionDestino,
    };
  }
}
