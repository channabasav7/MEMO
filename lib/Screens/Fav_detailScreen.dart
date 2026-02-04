import 'package:flutter/material.dart';
import 'package:favoriteplaces/data/fav_placedata.dart';

class FavDetailScreen extends StatelessWidget {
  const FavDetailScreen({super.key, required this.favPlace});

  final FavPlace favPlace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(favPlace.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(
              favPlace.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(favPlace.title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(favPlace.note, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
