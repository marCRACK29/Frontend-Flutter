import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../models/envio_model.dart';
import '../models/route_model.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import '../services/routing_service.dart';
import '../services/envio_service.dart';
import 'dart:async';

class ConductorTrackingScreen extends StatefulWidget {
  final String conductorId;

  const ConductorTrackingScreen({Key? key, required this.conductorId})
    : super(key: key);

  @override
  State<ConductorTrackingScreen> createState() =>
      _ConductorTrackingScreenState();
}

class _ConductorTrackingScreenState extends State<ConductorTrackingScreen> {
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  RouteResponse? _route;
  Envio? _selectedEnvio;
  List<Envio> _availableEnvios = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<LatLng>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    try {
      // Obtener ubicación actual
      _currentLocation = await LocationService.getCurrentLocation();
      
      // Obtener envíos disponibles
      _availableEnvios = await EnvioService.getEnviosByConductor(widget.conductorId);
      
      // Si hay envíos, seleccionar el primero automáticamente
      if (_availableEnvios.isNotEmpty) {
        await _selectEnvio(_availableEnvios.first);
      }
      
      // Escuchar actualizaciones de ubicación
      _locationSubscription = LocationService.getLocationStream().listen((location) {
        if (mounted) {
          setState(() {
            _currentLocation = location;
          });
          _updateRoute(); // Actualizar ruta cuando cambie la ubicación
        }
      });
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectEnvio(Envio envio) async {
    setState(() => _isLoading = true);
    
    try {
      _selectedEnvio = envio;
      
      // Obtener coordenadas del destino
      _destinationLocation = await GeocodingService.getCoordinatesFromAddress(
        envio.direccionDestino,
      );
      
      if (_destinationLocation == null) {
        throw Exception('No se pudo encontrar la dirección');
      }
      
      // Obtener ruta
      await _updateRoute();
      
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateRoute() async {
    if (_currentLocation != null && _destinationLocation != null) {
      try {
        _route = await RoutingService.getRoute(_currentLocation!, _destinationLocation!);
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('Error actualizando ruta: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking - Conductor'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Selector simple de envíos
          if (_availableEnvios.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<Envio>(
                value: _selectedEnvio,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Envío',
                  border: OutlineInputBorder(),
                ),
                items: _availableEnvios.map((envio) {
                  return DropdownMenuItem(
                    value: envio,
                    child: Text('Envío #${envio.id} - ${envio.direccionDestino}'),
                  );
                }).toList(),
                onChanged: _isLoading ? null : (envio) {
                  if (envio != null) _selectEnvio(envio);
                },
              ),
            ),
          
          // Mapa
          Expanded(child: _buildMap()),
          
          // Información de la ruta
          if (_selectedEnvio != null && _route != null)
            _buildRouteInfo(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                });
                _initializeTracking();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_currentLocation == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Obteniendo ubicación...'),
          ],
        ),
      );
    }

    // Calcular el centro del mapa
    LatLng mapCenter = _currentLocation!;
    double zoom = 15.0;
    
    if (_destinationLocation != null) {
      // Si tenemos destino, centrar entre origen y destino
      final bounds = LatLngBounds.fromPoints([_currentLocation!, _destinationLocation!]);
      mapCenter = bounds.center;
      zoom = 13.0;
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: mapCenter,
        initialZoom: zoom,
        minZoom: 5.0,
        maxZoom: 18.0,
      ),
      children: [
        // Capa de tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.conductor_tracking',
          tileProvider: CancellableNetworkTileProvider(),
        ),

        // Ruta
        if (_route?.coordinates.isNotEmpty == true)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _route!.coordinates,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),

        // Marcadores
        MarkerLayer(
          markers: [
            // Ubicación actual
            Marker(
              point: _currentLocation!,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

            // Destino
            if (_destinationLocation != null)
              Marker(
                point: _destinationLocation!,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.route, color: Colors.blue[700]),
              const SizedBox(height: 4),
              Text(
                '${(_route!.distance / 1000).toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Distancia', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, color: Colors.blue[700]),
              const SizedBox(height: 4),
              Text(
                '${(_route!.duration / 60).toStringAsFixed(0)} min',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Tiempo', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_shipping, color: Colors.blue[700]),
              const SizedBox(height: 4),
              Text(
                '#${_selectedEnvio!.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Envío', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}