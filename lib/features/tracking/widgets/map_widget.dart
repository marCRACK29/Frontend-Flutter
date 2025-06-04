import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/geocoding_service.dart';

class TrackingMapWidget extends StatefulWidget {
  final String destinationAddress;
  final double? currentLat;
  final double? currentLng;

  const TrackingMapWidget({
    Key? key,
    required this.destinationAddress,
    this.currentLat,
    this.currentLng,
  }) : super(key: key);

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Obtener ubicación actual
      if (widget.currentLat != null && widget.currentLng != null) {
        _currentPosition = LatLng(widget.currentLat!, widget.currentLng!);
      } else {
        final position = await _getCurrentLocation();
        _currentPosition = LatLng(position.latitude, position.longitude);
      }

      // Obtener coordenadas del destino
      if (widget.destinationAddress.isNotEmpty) {
        debugPrint(
          '🎯 Obteniendo coordenadas para: ${widget.destinationAddress}',
        );
        final destinationCoords =
            await GeocodingService.getCoordinatesFromAddress(
              widget.destinationAddress,
            );
        _destinationPosition = LatLng(
          destinationCoords['latitude']!,
          destinationCoords['longitude']!,
        );
      } else {
        debugPrint('⚠️ No hay dirección de destino');
        throw Exception('No se proporcionó una dirección de destino');
      }

      if (_currentPosition != null && _destinationPosition != null) {
        await _calculateRoute();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error inicializando mapa: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están deshabilitados');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Los permisos de ubicación fueron denegados');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _calculateRoute() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/'
          '${_currentPosition!.longitude},${_currentPosition!.latitude};'
          '${_destinationPosition!.longitude},${_destinationPosition!.latitude}'
          '?overview=full&geometries=geojson',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok') {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;
          _routePoints =
              coordinates
                  .map(
                    (coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()),
                  )
                  .toList();

          // Centrar el mapa en la ruta
          _mapController.fitBounds(
            LatLngBounds.fromPoints(_routePoints),
            options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
          );
        }
      }
    } catch (e) {
      debugPrint('Error calculando ruta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentPosition == null) {
      return const Center(
        child: Text('No se pudo obtener tu ubicación actual'),
      );
    }

    if (_destinationPosition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No se pudo obtener la ubicación del destino'),
            const SizedBox(height: 16),
            Text('Dirección: ${widget.destinationAddress}'),
          ],
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: _currentPosition!, initialZoom: 15.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _currentPosition!,
              width: 80,
              height: 80,
              child: const Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 40,
              ),
            ),
            Marker(
              point: _destinationPosition!,
              width: 80,
              height: 80,
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            if (_routePoints.isNotEmpty)
              Polyline(
                points: _routePoints,
                color: Colors.blue,
                strokeWidth: 4.0,
              ),
          ],
        ),
      ],
    );
  }
}
