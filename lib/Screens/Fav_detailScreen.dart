import 'package:flutter/material.dart';
import 'package:favoriteplaces/data/fav_placedata.dart';

class FavDetailScreen extends StatelessWidget {
  const FavDetailScreen({super.key, required this.favPlace});

  final FavPlace favPlace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(favPlace.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: favPlace.imageBytes != null
                  ? Image.memory(favPlace.imageBytes!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 64),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            favPlace.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (favPlace.address != null && favPlace.address!.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    favPlace.address!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Text(
            favPlace.note,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
