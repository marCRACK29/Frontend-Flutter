class Cliente {
  final String rut;
  final String nombre;
  final String correo;
  final String? calle;
  final int? numeroDomicilio;
  final String? ciudad;
  final String? region;
  final int? codigoPostal;

  Cliente({
    required this.rut,
    required this.nombre,
    required this.correo,
    this.calle,
    this.numeroDomicilio,
    this.ciudad,
    this.region,
    this.codigoPostal,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      rut: json['rut'],
      nombre: json['nombre'],
      correo: json['correo'],
      calle: json['calle'],
      numeroDomicilio: json['numero_domicilio'],
      ciudad: json['ciudad'],
      region: json['region'],
      codigoPostal: json['codigo_postal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rut': rut,
      'nombre': nombre,
      'correo': correo,
      'calle': calle,
      'numero_domicilio': numeroDomicilio,
      'ciudad': ciudad,
      'region': region,
      'codigo_postal': codigoPostal,
    };
  }
} 