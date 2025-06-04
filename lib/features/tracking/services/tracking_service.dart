import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:location/location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrackingService extends ChangeNotifier {
  IO.Socket? _socket;
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  // Estado del tracking
  bool _isConnected = false;
  bool _isTracking = false;
  int? _currentEnvioId;
  Map<String, dynamic>? _currentEnvioStatus;
  LocationData? _currentLocation;

  // Getters
  bool get isConnected => _isConnected;
  bool get isTracking => _isTracking;
  int? get currentEnvioId => _currentEnvioId;
  Map<String, dynamic>? get currentEnvioStatus {
    print('🔍 Getter currentEnvioStatus llamado - Valor: $_currentEnvioStatus');
    return _currentEnvioStatus;
  }

  LocationData? get currentLocation => _currentLocation;

  // URL del backend desde variables de entorno
  String get _serverUrl =>
      dotenv.env['API_URL'] ?? 'https://tu-ngrok-url.ngrok-free.app';

  // Inicializar conexión
  Future<void> initialize() async {
    try {
      _socket = IO.io(_serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _setupSocketListeners();
      _socket!.connect();
    } catch (e) {
      print('Error inicializando tracking: $e');
    }
  }

  void _setupSocketListeners() {
    _socket!.on('connect', (_) {
      debugPrint('✅ Conectado al servidor de tracking');
      _isConnected = true;
      notifyListeners();
    });

    _socket!.on('disconnect', (_) {
      debugPrint('❌ Desconectado del servidor');
      _isConnected = false;
      notifyListeners();
    });

    _socket!.on('connected', (data) {
      debugPrint('✅ Confirmación de conexión: ${data['message']}');
    });

    _socket!.on('joined_tracking', (data) {
      debugPrint('✅ Unido al tracking: ${data['message']}');
      _isTracking = true;
      notifyListeners();
    });

    // Nuevo evento para actualización de ubicación del conductor
    _socket!.on('conductor_location_update', (data) {
      debugPrint('📍 Actualización de ubicación del conductor:');
      debugPrint('   Data: $data');

      try {
        if (data is Map) {
          // Actualizar el estado actual con la nueva ubicación
          if (_currentEnvioStatus != null) {
            _currentEnvioStatus = {
              ..._currentEnvioStatus!,
              'latitude': data['latitud'],
              'longitude': data['longitud'],
              'last_location_update': data['timestamp'],
            };
            debugPrint('✅ Ubicación actualizada:');
            debugPrint('   Latitud: ${data['latitud']}');
            debugPrint('   Longitud: ${data['longitud']}');
            debugPrint('   Timestamp: ${data['timestamp']}');
          } else {
            debugPrint('⚠️ No hay estado de envío para actualizar');
          }
        } else {
          debugPrint('❌ Data no es Map: $data');
        }
      } catch (e) {
        debugPrint('❌ Error procesando actualización de ubicación: $e');
      }

      notifyListeners();
    });

    _socket!.on('status_update', (data) {
      debugPrint('📝 Status update recibido:');
      debugPrint('   Data: $data');

      try {
        if (data is Map) {
          // Asegurar que las coordenadas estén en el formato correcto
          if (data['latitude'] != null) {
            data['latitude'] = _parseCoordinate(data['latitude']);
          }
          if (data['longitude'] != null) {
            data['longitude'] = _parseCoordinate(data['longitude']);
          }

          // Combinar con el estado actual
          _currentEnvioStatus = {
            ..._currentEnvioStatus ?? {},
            ...Map<String, dynamic>.from(data),
            // Asegurar que las direcciones estén presentes
            'direccion_origen':
                data['direccion_origen'] ??
                _currentEnvioStatus?['direccion_origen'],
            'direccion_destino':
                data['direccion_destino'] ??
                _currentEnvioStatus?['direccion_destino'],
          };

          debugPrint('✅ Status actualizado:');
          debugPrint('   Estado: ${_currentEnvioStatus!['estado']}');
          debugPrint('   Latitud: ${_currentEnvioStatus!['latitude']}');
          debugPrint('   Longitud: ${_currentEnvioStatus!['longitude']}');
          debugPrint('   Origen: ${_currentEnvioStatus!['direccion_origen']}');
          debugPrint(
            '   Destino: ${_currentEnvioStatus!['direccion_destino']}',
          );
        } else {
          debugPrint('❌ Data no es Map: $data');
        }
      } catch (e) {
        debugPrint('❌ Error procesando status_update: $e');
      }

      notifyListeners();
    });

    _socket!.on('location_update', (data) {
      debugPrint('📍 Location update recibido:');
      debugPrint('   Data: $data');

      try {
        if (data is Map) {
          // Crear nuevo status combinando el anterior con la nueva ubicación
          Map<String, dynamic> newStatus = {
            ..._currentEnvioStatus ?? {},
            ...Map<String, dynamic>.from(data),
          };

          // Asegurar que las coordenadas estén en el formato correcto
          if (data['latitude'] != null) {
            newStatus['latitude'] = _parseCoordinate(data['latitude']);
          }
          if (data['longitude'] != null) {
            newStatus['longitude'] = _parseCoordinate(data['longitude']);
          }

          _currentEnvioStatus = newStatus;

          debugPrint('   ✅ Status actualizado con ubicación:');
          debugPrint('      Latitude: ${_currentEnvioStatus!['latitude']}');
          debugPrint('      Longitude: ${_currentEnvioStatus!['longitude']}');
        } else {
          debugPrint('   ❌ Data no es Map: $data');
        }
      } catch (e) {
        debugPrint('   ❌ Error procesando location_update: $e');
      }

      notifyListeners();
    });

    _socket!.on('error', (data) {
      debugPrint('❌ Socket error: ${data['message']}');
    });
  }

  // Método auxiliar para parsear coordenadas
  double? _parseCoordinate(dynamic coord) {
    if (coord == null) return null;

    if (coord is double) return coord;
    if (coord is int) return coord.toDouble();
    if (coord is String) {
      try {
        return double.parse(coord);
      } catch (e) {
        debugPrint('❌ Error parseando coordenada: $coord');
        return null;
      }
    }

    debugPrint('❌ Tipo de coordenada no reconocido: ${coord.runtimeType}');
    return null;
  }

  // Método para debug - forzar actualización manual
  void forceUpdateForDebug() {
    debugPrint('🧪 Forzando actualización de debug');

    if (_currentLocation != null) {
      debugPrint('📍 Usando ubicación actual:');
      debugPrint('   Latitud: ${_currentLocation!.latitude}');
      debugPrint('   Longitud: ${_currentLocation!.longitude}');

      _currentEnvioStatus = {
        'latitude': _currentLocation!.latitude,
        'longitude': _currentLocation!.longitude,
        'estado': 'en_camino',
        'conductor_nombre': 'Test Driver',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } else {
      debugPrint('⚠️ No hay ubicación actual disponible para debug');
      debugPrint('   Verifica que:');
      debugPrint('   1. Los permisos de ubicación estén concedidos');
      debugPrint('   2. El servicio de ubicación esté activado');
      debugPrint('   3. El usuario sea de tipo conductor');

      // Intentar obtener la ubicación actual
      _location
          .getLocation()
          .then((locationData) {
            if (locationData.latitude != null &&
                locationData.longitude != null) {
              debugPrint('✅ Ubicación obtenida:');
              debugPrint('   Latitud: ${locationData.latitude}');
              debugPrint('   Longitud: ${locationData.longitude}');

              _currentLocation = locationData;
              _currentEnvioStatus = {
                'latitude': locationData.latitude,
                'longitude': locationData.longitude,
                'estado': 'en_camino',
                'conductor_nombre': 'Test Driver',
                'timestamp': DateTime.now().toIso8601String(),
              };
              notifyListeners();
            } else {
              debugPrint('❌ No se pudo obtener la ubicación');
            }
          })
          .catchError((error) {
            debugPrint('❌ Error obteniendo ubicación: $error');
          });
    }

    notifyListeners();
  }

  Future<void> joinTracking(int envioId, String userType, String userId) async {
    debugPrint('🔄 Uniéndose al tracking:');
    debugPrint('   Envío ID: $envioId');
    debugPrint('   Tipo de usuario: $userType');
    debugPrint('   User ID: $userId');

    _currentEnvioId = envioId;

    // Obtener información del envío
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/envio/$envioId'),
      );

      if (response.statusCode == 200) {
        final envioData = json.decode(response.body);
        debugPrint('📦 Información del envío obtenida:');
        debugPrint('   Origen: ${envioData['direccion_origen']}');
        debugPrint('   Destino: ${envioData['direccion_destino']}');

        _currentEnvioStatus = {
          'estado': envioData['estado_actual']['estado'] ?? 'pendiente',
          'timestamp': DateTime.now().toIso8601String(),
          'direccion_origen': envioData['direccion_origen'],
          'direccion_destino': envioData['direccion_destino'],
        };
      } else {
        debugPrint(
          '⚠️ Error obteniendo información del envío: ${response.statusCode}',
        );
        _currentEnvioStatus = {
          'estado': 'pendiente',
          'timestamp': DateTime.now().toIso8601String(),
          'direccion_origen': null,
          'direccion_destino': null,
        };
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo información del envío: $e');
      _currentEnvioStatus = {
        'estado': 'pendiente',
        'timestamp': DateTime.now().toIso8601String(),
        'direccion_origen': null,
        'direccion_destino': null,
      };
    }

    // Esperar a que el socket esté conectado
    if (_socket == null || !_socket!.connected) {
      debugPrint('⏳ Esperando conexión de socket...');
      await _waitForSocketConnection();
    }

    debugPrint('✅ Socket conectado, enviando join_tracking');
    _socket!.emit('join_tracking', {
      'envio_id': envioId,
      'user_type': userType,
      'user_id': userId,
    });

    if (userType == 'conductor') {
      debugPrint('🚗 Usuario es conductor, obteniendo ubicación inicial...');
      try {
        final locationData = await _location.getLocation();
        if (locationData.latitude != null && locationData.longitude != null) {
          _currentLocation = locationData;
          _currentEnvioStatus!['latitude'] = locationData.latitude;
          _currentEnvioStatus!['longitude'] = locationData.longitude;
          debugPrint('📍 Ubicación inicial obtenida:');
          debugPrint('   Latitud: ${locationData.latitude}');
          debugPrint('   Longitud: ${locationData.longitude}');
        } else {
          debugPrint('⚠️ No se pudo obtener ubicación inicial');
        }
      } catch (e) {
        debugPrint('❌ Error obteniendo ubicación inicial: $e');
      }
    }

    notifyListeners();
  }

  Future<void> _waitForSocketConnection() async {
    const timeout = Duration(seconds: 5);
    final start = DateTime.now();

    while (_socket != null && !_socket!.connected) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (DateTime.now().difference(start) > timeout) {
        print('❌ No se pudo conectar al socket a tiempo');
        return;
      }
    }
  }

  // Dejar de trackear un envío
  void leaveTracking() {
    if (_socket != null && _currentEnvioId != null) {
      _socket!.emit('leave_tracking', {'envio_id': _currentEnvioId});

      _currentEnvioId = null;
      _currentEnvioStatus = null;
      _isTracking = false;
      notifyListeners();
    }
  }

  // Iniciar seguimiento de ubicación (para conductores)
  Future<void> startLocationTracking(String conductorId) async {
    debugPrint(
      '🚗 Iniciando tracking de ubicación para conductor: $conductorId',
    );

    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      debugPrint(
        '⚠️ Servicio de ubicación desactivado, solicitando activación...',
      );
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        debugPrint('❌ No se pudo activar el servicio de ubicación');
        return;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      debugPrint('⚠️ Permiso de ubicación denegado, solicitando...');
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        debugPrint('❌ No se pudo obtener permiso de ubicación');
        return;
      }
    }

    debugPrint('✅ Permisos de ubicación concedidos, iniciando tracking...');

    _locationSubscription = _location.onLocationChanged.listen(
      (LocationData locationData) {
        debugPrint('📍 Nueva ubicación detectada:');
        debugPrint('   Latitud: ${locationData.latitude}');
        debugPrint('   Longitud: ${locationData.longitude}');

        _currentLocation = locationData;

        // Actualizar el estado actual con la nueva ubicación
        if (_currentEnvioStatus != null) {
          _currentEnvioStatus = {
            ..._currentEnvioStatus!,
            'latitude': locationData.latitude,
            'longitude': locationData.longitude,
            'last_location_update': DateTime.now().toIso8601String(),
          };
        }

        // Enviar ubicación al servidor
        if (_socket != null && _isConnected) {
          debugPrint('📤 Enviando ubicación al servidor...');
          _socket!.emit('update_location', {
            'conductor_id': conductorId,
            'latitude': locationData.latitude,
            'longitude': locationData.longitude,
            'timestamp': DateTime.now().toIso8601String(),
          });
        } else {
          debugPrint('⚠️ No se pudo enviar ubicación: Socket no conectado');
        }

        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error en el tracking de ubicación: $error');
      },
    );

    debugPrint('✅ Tracking de ubicación iniciado correctamente');
  }

  // Detener seguimiento de ubicación
  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _currentLocation = null;
    notifyListeners();
  }

  // Desconectar
  void disconnect() {
    stopLocationTracking();
    leaveTracking();
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
