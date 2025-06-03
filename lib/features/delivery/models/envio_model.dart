class EnvioModel {
  final int id;
  final String direccion;
  final String contacto;
  final String instrucciones;
  final String estado;
  final double? lat;
  final double? lng;

  EnvioModel({
    required this.id,
    required this.direccion,
    required this.contacto,
    required this.instrucciones,
    required this.estado,
    this.lat,
    this.lng,
  });

  factory EnvioModel.fromJson(Map<String, dynamic> json) {
    return EnvioModel(
      id: json['id_envio'],
      direccion: json['direccion'] ?? '',
      contacto: json['contacto'] ?? '',
      instrucciones: json['instrucciones'] ?? '',
      estado: json['estado'] ?? '',
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_envio': id,
      'direccion': direccion,
      'contacto': contacto,
      'instrucciones': instrucciones,
      'estado': estado,
      'lat': lat,
      'lng': lng,
    };
  }
}
