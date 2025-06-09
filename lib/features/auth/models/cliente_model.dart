class ClienteModel {
  final String rut;
  final String nombre;
  final String correo;
  final DireccionModel? direccion;

  ClienteModel({
    required this.rut,
    required this.nombre,
    required this.correo,
    this.direccion,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      rut: json['RUT'] ?? json['id'] ?? '',
      nombre: json['nombre'] ?? json['name'] ?? '',
      correo: json['correo'] ?? json['email'] ?? '',
      direccion:
          json['direccion'] != null
              ? DireccionModel.fromJson(json['direccion'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RUT': rut,
      'nombre': nombre,
      'correo': correo,
      if (direccion != null) 'direccion': direccion!.toJson(),
    };
  }
}

class DireccionModel {
  final int numeroDomicilio;
  final String calle;
  final String ciudad;
  final String region;
  final int codigoPostal;

  DireccionModel({
    required this.numeroDomicilio,
    required this.calle,
    required this.ciudad,
    required this.region,
    required this.codigoPostal,
  });

  factory DireccionModel.fromJson(Map<String, dynamic> json) {
    return DireccionModel(
      numeroDomicilio: json['numero_domicilio'] ?? 0,
      calle: json['calle'] ?? '',
      ciudad: json['ciudad'] ?? '',
      region: json['region'] ?? '',
      codigoPostal: json['codigo_postal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero_domicilio': numeroDomicilio,
      'calle': calle,
      'ciudad': ciudad,
      'region': region,
      'codigo_postal': codigoPostal,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterClienteRequest {
  final String rut;
  final String nombre;
  final String correo;
  final String contrasena;
  final int numeroDomicilio;
  final String calle;
  final String ciudad;
  final String region;
  final int codigoPostal;

  RegisterClienteRequest({
    required this.rut,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.numeroDomicilio,
    required this.calle,
    required this.ciudad,
    required this.region,
    required this.codigoPostal,
  });

  Map<String, dynamic> toJson() {
    return {
      'RUT': rut,
      'nombre': nombre,
      'correo': correo,
      'contraseña': contrasena,
      'numero_domicilio': numeroDomicilio,
      'calle': calle,
      'ciudad': ciudad,
      'region': region,
      'codigo_postal': codigoPostal,
    };
  }
}
