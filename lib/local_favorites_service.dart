import 'dart:convert';

import 'package:favoriteplaces/data/fav_placedata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalFavoritesService {
  static const String _keyPrefix = 'favorite_places_';

  String _storageKey(String userId) => '$_keyPrefix$userId';

  Future<List<FavPlace>> getUserPlaces(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_storageKey(userId));

    if (payload == null || payload.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(payload) as List<dynamic>;
    return decoded
        .map((item) => FavPlace.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> saveUserPlaces(String userId, List<FavPlace> places) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(places.map((place) => place.toMap()).toList());
    await prefs.setString(_storageKey(userId), payload);
  }

  Future<void> addPlace(String userId, FavPlace place) async {
    final places = await getUserPlaces(userId);
    await saveUserPlaces(userId, [...places, place]);
  }

  Future<void> deletePlace(String userId, String placeId) async {
    final places = await getUserPlaces(userId);
    await saveUserPlaces(
      userId,
      places.where((place) => place.id != placeId).toList(),
    );
  }

  Future<void> updatePlace(String userId, String placeId, FavPlace updatedPlace) async {
    final places = await getUserPlaces(userId);
    final updated = places
        .map((place) => place.id == placeId ? updatedPlace.copyWith(id: placeId) : place)
        .toList();
    await saveUserPlaces(userId, updated);
  }

  Future<List<FavPlace>> searchPlaces(String userId, String query) async {
    final places = await getUserPlaces(userId);
    final normalized = query.toLowerCase().trim();

    if (normalized.isEmpty) {
      return places;
    }

    return places.where((place) {
      return place.title.toLowerCase().contains(normalized) ||
          place.note.toLowerCase().contains(normalized) ||
          (place.address?.toLowerCase().contains(normalized) ?? false);
    }).toList();
  }
}
