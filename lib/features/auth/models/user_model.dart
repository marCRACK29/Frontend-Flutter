
enum UserKind {
  client,
  delivery,
}

class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final UserKind kind;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.kind = UserKind.client,
  });
  
  

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phone: json['phone'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
      isActive: json['is_active'] ?? true,
       kind: _parseUserKind(json['kind']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'kind': kind.name,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    UserKind? kind,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      kind: kind ?? this.kind,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, kind: ${kind.name})';
  }
  static UserKind _parseUserKind(dynamic value) {
    if (value == null) return UserKind.client;
    
    try {
      return UserKind.values.firstWhere(
        (kind) => kind.name == value.toString().toLowerCase(),
        orElse: () => UserKind.client,
      );
    } catch (e) {
      return UserKind.client;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class LoginRequest {
  final String email;
  final String password; 
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'remember_me': rememberMe,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String? name;
  final String? phone;

  RegisterRequest({
    required this.email,
    required this.password,
    this.name,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;
  final String tokenType;
  final int expiresIn;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.tokenType = 'Bearer',
    this.expiresIn = 3600,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 3600,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}