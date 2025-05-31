// features/maps/widgets/map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:frontend/features/maps/providers/map_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mapState = context.watch<MapProvider>();
    return FlutterMap(
      mapController: mapState.mapController,
      options: MapOptions(
        initialCenter: mapState.currentLocation ?? const LatLng(0, 0),
        initialZoom: 15,
      ),
      children: [
        TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
        CurrentLocationLayer(
          style: const LocationMarkerStyle(
            marker: DefaultLocationMarker(
              child: Icon(Icons.location_pin, color: Colors.red),
            ),
            markerSize: Size(35, 35),
            markerDirection: MarkerDirection.heading,
          ),
        ),
        if (mapState.destination != null)
          MarkerLayer(
            markers: [
              Marker(
                point: mapState.destination!,
                width: 50,
                height: 50,
                child: Icon(
                  Icons.location_pin,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ]
          ),
        if (mapState.route.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: mapState.route,
                strokeWidth: 5,
                color: Colors.red,
              ),
            ]
          ),
      ],
    );
  }
}
