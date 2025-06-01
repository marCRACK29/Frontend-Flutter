import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:location/location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TrackingService extends ChangeNotifier {
  IO.Socket? _socket;
  Location _location = Location();
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
  Map<String, dynamic>? get currentEnvioStatus => _currentEnvioStatus;
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
      print('Conectado al servidor de tracking');
      _isConnected = true;
      notifyListeners();
    });

    _socket!.on('disconnect', (_) {
      print('Desconectado del servidor');
      _isConnected = false;
      notifyListeners();
    });

    _socket!.on('connected', (data) {
      print('Confirmación de conexión: ${data['message']}');
    });

    _socket!.on('joined_tracking', (data) {
      print('Unido al tracking: ${data['message']}');
      _isTracking = true;
      notifyListeners();
    });

    _socket!.on('status_update', (data) {
      print('Actualización de estado: $data');
      _currentEnvioStatus = Map<String, dynamic>.from(data);
      notifyListeners();
    });

    _socket!.on('location_update', (data) {
      print('Actualización de ubicación: $data');
      _currentEnvioStatus = {...?_currentEnvioStatus, ...data};
      notifyListeners();
    });

    _socket!.on('error', (data) {
      print('Error: ${data['message']}');
    });
  }

  Future<void> joinTracking(int envioId, String userType, String userId) async {
    _currentEnvioId = envioId;

    // Esperar a que el socket esté conectado
    if (_socket == null || !_socket!.connected) {
      print('⏳ Esperando conexión de socket...');
      await _waitForSocketConnection();
    }

    print('✅ Uniéndose a tracking: envio_id=$envioId, user_id=$userId');
    _socket!.emit('join_tracking', {
      'envio_id': envioId,
      'user_type': userType, // 'cliente' o 'conductor'
      'user_id': userId,
    });
  }
  
  Future<void> _waitForSocketConnection() async {
    const timeout = Duration(seconds: 5);
    final start = DateTime.now();

    while (!_socket!.connected) {
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
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationSubscription = _location.onLocationChanged.listen((
      LocationData locationData,
    ) {
      _currentLocation = locationData;

      // Enviar ubicación al servidor
      if (_socket != null && _isConnected) {
        _socket!.emit('update_location', {
          'conductor_id': conductorId,
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
        });
      }

      notifyListeners();
    });
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
