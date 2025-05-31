import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:frontend/features/maps/providers/map_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

/// Widget que muestra el mapa interactivo con OpenStreetMap
class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mapState = context.watch<MapProvider>(); // Observa la clase provider/map_provider.dart
    
    return FlutterMap(
      mapController: mapState.mapController,
      options: MapOptions(
        initialCenter: mapState.ubicacionActual ?? const LatLng(0, 0),
        initialZoom: 15,
        minZoom: 0,
        maxZoom: 100,
      ),
      children: [
        // Capa base del mapa con tiles de OpenStreetMap
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          tileProvider: CancellableNetworkTileProvider(),
        ),
        // Capa que muestra la ubicación actual del usuario
        CurrentLocationLayer(
          style: const LocationMarkerStyle(
            marker: DefaultLocationMarker(
              // Ícono de ubicacion actual del usuario (en rojo)
              child: Icon(Icons.location_pin, color: Colors.red),
            ),
            markerSize: Size(35, 35),
            markerDirection: MarkerDirection.heading,
          ),
        ),
        // Marcador del destino si existe
        if (mapState.destino != null)
          MarkerLayer(
            markers: [
              Marker(
                point: mapState.destino!,
                width: 50,
                height: 50,
                child: Icon(Icons.location_pin, size: 40, color: Colors.red),
              ),
            ],
          ),
        // Línea de ruta si existe
        if (mapState.route.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: mapState.route,
                strokeWidth: 5,
                color: Colors.red,
              ),
            ],
          ),
      ],
    );
  }
}
