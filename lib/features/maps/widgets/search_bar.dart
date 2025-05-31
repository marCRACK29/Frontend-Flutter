// features/maps/widgets/search_bar.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/maps/providers/map_provider.dart';
import 'package:provider/provider.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MapProvider>().searchController;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Ingresa una ubicación'),
            ),
          ),
          IconButton(
            onPressed: () => context.read<MapProvider>().searchLocation(),
            icon: const Icon(Icons.search),
          )
        ],
      ),
    );
  }
}
