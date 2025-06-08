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
import '../widgets/envio_selector_widget.dart';

class ConductorTrackingScreen extends StatefulWidget {
  final String conductorId;

  const ConductorTrackingScreen({Key? key, required this.conductorId})
    : super(key: key);

  @override
  State<ConductorTrackingScreen> createState() =>
      _ConductorTrackingScreenState();
}

class _ConductorTrackingScreenState extends State<ConductorTrackingScreen> {
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  RouteResponse? _route;
  Envio? _selectedEnvio;
  List<Envio> _availableEnvios = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    setState(() => _isLoading = true);

    try {
      // Get current location
      _currentLocation = await LocationService.getCurrentLocation();

      // Get available envios for conductor
      _availableEnvios = await EnvioService.getEnviosByConductor(
        widget.conductorId,
      );

      // Listen to location updates
      LocationService.getLocationStream().listen((location) {
        if (mounted) {
          setState(() => _currentLocation = location);
          if (_destinationLocation != null) {
            _updateRoute();
          }
        }
      });
    } catch (e) {
      _errorMessage = 'Error initializing tracking: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectEnvio(Envio envio) async {
    setState(() => _isLoading = true);

    try {
      _selectedEnvio = envio;

      // Geocode destination address
      _destinationLocation = await GeocodingService.getCoordinatesFromAddress(
        envio.direccionDestino,
      );

      if (_destinationLocation == null) {
        throw Exception('No se pudo encontrar la dirección de destino');
      }

      // Get route if we have current location
      if (_currentLocation != null) {
        await _updateRoute();
        _centerMapOnRoute();
      }
    } catch (e) {
      _errorMessage = 'Error selecting envio: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRoute() async {
    if (_currentLocation != null && _destinationLocation != null) {
      _route = await RoutingService.getRoute(
        _currentLocation!,
        _destinationLocation!,
      );
      if (mounted) setState(() {});
    }
  }

  void _centerMapOnRoute() {
    if (_currentLocation != null && _destinationLocation != null) {
      final bounds = LatLngBounds.fromPoints([
        _currentLocation!,
        _destinationLocation!,
      ]);

      _mapController.move(bounds.center, _mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking - Conductor'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          if (_selectedEnvio != null)
            IconButton(
              icon: const Icon(Icons.center_focus_strong),
              onPressed: _centerMapOnRoute,
              tooltip: 'Centrar mapa',
            ),
        ],
      ),
      body: Column(
        children: [
          // Envio Selector
          EnvioSelectorWidget(
            envios: _availableEnvios,
            selectedEnvio: _selectedEnvio,
            onEnvioSelected: _selectEnvio,
            isLoading: _isLoading,
          ),

          // Map
          Expanded(child: _buildMap()),

          // Status Bar
          if (_selectedEnvio != null) _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _errorMessage = null);
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

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation!,
        initialZoom: 15.0,
        minZoom: 5.0,
        maxZoom: 18.0,
      ),
      children: [
        // Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.conductor_tracking',
          tileProvider: CancellableNetworkTileProvider(),
        ),

        // Route Polyline
        if (_route?.coordinates.isNotEmpty == true)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _route!.coordinates,
                strokeWidth: 5.0,
                color: Colors.blue,
              ),
            ],
          ),

        // Markers
        MarkerLayer(
          markers: [
            // Current location marker
            Marker(
              point: _currentLocation!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

            // Destination marker
            if (_destinationLocation != null)
              Marker(
                point: _destinationLocation!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withAlpha(26),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Envío #${_selectedEnvio!.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _selectedEnvio!.direccionDestino,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          if (_route != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Distancia', style: TextStyle(fontSize: 12)),
                    Text(
                      '${(_route!.distance / 1000).toStringAsFixed(1)} km',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Tiempo est.', style: TextStyle(fontSize: 12)),
                    Text(
                      '${(_route!.duration / 60).toStringAsFixed(0)} min',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
