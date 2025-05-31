// features/maps/views/openstreetmap_view.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/maps/providers/map_provider.dart';
import 'package:frontend/features/maps/widgets/map_widget.dart';
import 'package:provider/provider.dart';

class OpenStreetMapView extends StatelessWidget {
  const OpenStreetMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OpenStreetMap')),
      body: Stack(
        children: [
          MapWidget(), // mapa interactivo + ruta
          Positioned(top: 0, left: 0, right: 0, child: SearchBar()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<MapProvider>().centerUserLocation(),
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
