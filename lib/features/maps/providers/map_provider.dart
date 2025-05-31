
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/features/maps/services/api/nominatim_osrm_service.dart';
import 'package:frontend/features/maps/services/local/location_service.dart';
import 'package:latlong2/latlong.dart';

class MapProvider with ChangeNotifier {
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();
  LatLng? currentLocation;
  LatLng? destination;
  List<LatLng> route = [];

  final _locationService = LocationService();
  final _mapService = NominatimOsrmService();

  MapProvider() {
    _initLocation();
  }

  Future<void> _initLocation() async {
    currentLocation = await _locationService.getCurrentLocation();
    notifyListeners();
  }

  Future<void> searchLocation() async {
    final text = searchController.text;
    if (text.isEmpty) return;
    destination = await _mapService.searchLocation(text);
    route = await _mapService.fetchRoute(currentLocation!, destination!);
    notifyListeners();
  }

  void centerUserLocation() {
    if (currentLocation != null) {
      mapController.move(currentLocation!, 15);
    }
  }
}
