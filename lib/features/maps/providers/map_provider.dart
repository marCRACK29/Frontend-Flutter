import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/local/location_service.dart';
import '../services/api/nominatim_osrm_service.dart';

class MapProvider with ChangeNotifier {
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final NominatimOsrmService _mapService = NominatimOsrmService();

  LatLng? currentLocation;
  LatLng? destination;
  List<LatLng> route = [];
  bool isLoading = true;

  MapProvider() {
    _initLocation();
  }

  Future<void> _initLocation() async {
    currentLocation = await _locationService.getCurrentLocation();
    isLoading = false;
    notifyListeners();
  }

  Future<void> searchLocation() async {
    final text = searchController.text.trim();
    if (text.isEmpty) return;

    destination = await _mapService.searchLocation(text);
    if (destination != null && currentLocation != null) {
      route = await _mapService.fetchRoute(currentLocation!, destination!);
    }
    notifyListeners();
  }

  void centerUserLocation() {
    if (currentLocation != null) {
      mapController.move(currentLocation!, 15);
    }
  }
}
