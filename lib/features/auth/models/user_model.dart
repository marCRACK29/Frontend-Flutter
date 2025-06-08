// user_model.dart
class User {
  final String rut;
  final String nombre;
  final String correo;
  final String tipo;
  final int? numero_domicilio;
  final String? calle;
  final String? ciudad;
  final String? region;
  final int? codigo_postal;

  User({
    required this.rut,
    required this.nombre,
    required this.correo,
    required this.tipo,
    this.numero_domicilio,
    this.calle,
    this.ciudad,
    this.region,
    this.codigo_postal,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      rut: json['id'] ?? json['rut'] ?? '',
      nombre: json['name'] ?? json['nombre'] ?? '',
      correo: json['email'] ?? json['correo'] ?? '',
      tipo: json['tipo'] ?? 'cliente',
      numero_domicilio: json['direccion']?['numero_domicilio'],
      calle: json['direccion']?['calle'],
      ciudad: json['direccion']?['ciudad'],
      region: json['direccion']?['region'],
      codigo_postal: json['direccion']?['codigo_postal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rut': rut,
      'nombre': nombre,
      'correo': correo,
      'tipo': tipo,
      'numero_domicilio': numero_domicilio,
      'calle': calle,
      'ciudad': ciudad,
      'region': region,
      'codigo_postal': codigo_postal,
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

class RegisterRequest {
  final String rut;
  final String nombre;
  final String correo;
  final String contrasena;
  final int numero_domicilio;
  final String calle;
  final String ciudad;
  final String region;
  final int codigo_postal;

  RegisterRequest({
    required this.rut,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.numero_domicilio,
    required this.calle,
    required this.ciudad,
    required this.region,
    required this.codigo_postal,
  });

  Map<String, dynamic> toJson() {
    return {
      'RUT': rut,
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
      'numero_domicilio': numero_domicilio,
      'calle': calle,
      'ciudad': ciudad,
      'region': region,
      'codigo_postal': codigo_postal,
    };
  }
}

class AuthResponse {
  final String message;
  final String token;
  final User user;

  AuthResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? json['mensaje'] ?? '',
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? json['usuario'] ?? {}),
    );
  }

  // Para compatibilidad con tu provider actual
  String get accessToken => token;
  String get refreshToken => token; // Usar el mismo token como refresh
}
