import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';

/// Widget que muestra la barra de búsqueda para encontrar ubicaciones en el mapa
class MapSearchBar extends StatelessWidget {
  const MapSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MapProvider>().searchController;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Campo de texto para ingresar la ubicación
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ingresa una ubicación',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          // Botón de búsqueda
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () => context.read<MapProvider>().searchLocation(),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
