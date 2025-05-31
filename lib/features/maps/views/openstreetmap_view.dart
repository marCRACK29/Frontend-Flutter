// features/maps/views/openstreetmap_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../widgets/map_widget.dart';
import '../widgets/search_bar.dart';

class OpenStreetMapView extends StatelessWidget {
  const OpenStreetMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final mapState = context.watch<MapProvider>();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('OpenStreetMap'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          mapState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : const MapWidget(),
          const Positioned(top: 0, right: 0, left: 0, child: MapSearchBar()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () => context.read<MapProvider>().centerUserLocation(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location, size: 30, color: Colors.white),
      ),
    );
  }
}
