import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favoriteplaces/data/fav_placedata.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String placesCollection = 'places';

  /// Get user places collection reference
  CollectionReference<Map<String, dynamic>> getUserPlacesCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection(placesCollection);
  }

  /// Add a new favorite place
  Future<String> addPlace(String userId, FavPlace place) async {
    try {
      final docRef = await getUserPlacesCollection(userId).add({
        'id': place.id,
        'title': place.title,
        'note': place.note,
        'imageUrl': place.imageUrl,
        'latitude': place.latitude,
        'longitude': place.longitude,
        'address': place.address,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Failed to add place: $e';
    }
  }

  /// Get all favorite places for a user
  Future<List<FavPlace>> getUserPlaces(String userId) async {
    try {
      final snapshot = await getUserPlacesCollection(userId).get();
      return snapshot.docs
          .map((doc) => FavPlace.fromMap({...doc.data(), 'docId': doc.id}))
          .toList();
    } catch (e) {
      throw 'Failed to fetch places: $e';
    }
  }

  /// Stream of user places
  Stream<List<FavPlace>> getUserPlacesStream(String userId) {
    try {
      return getUserPlacesCollection(userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  FavPlace.fromMap({...doc.data(), 'docId': doc.id}))
              .toList());
    } catch (e) {
      throw 'Failed to stream places: $e';
    }
  }

  /// Update a favorite place
  Future<void> updatePlace(String userId, String docId, FavPlace place) async {
    try {
      await getUserPlacesCollection(userId).doc(docId).update({
        'title': place.title,
        'note': place.note,
        'imageUrl': place.imageUrl,
        'latitude': place.latitude,
        'longitude': place.longitude,
        'address': place.address,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update place: $e';
    }
  }

  /// Delete a favorite place
  Future<void> deletePlace(String userId, String docId) async {
    try {
      await getUserPlacesCollection(userId).doc(docId).delete();
    } catch (e) {
      throw 'Failed to delete place: $e';
    }
  }

  /// Search places by title
  Future<List<FavPlace>> searchPlaces(
    String userId,
    String query,
  ) async {
    try {
      final snapshot =
          await getUserPlacesCollection(userId).get();
      final allPlaces = snapshot.docs
          .map((doc) => FavPlace.fromMap({...doc.data(), 'docId': doc.id}))
          .toList();
      
      return allPlaces
          .where((place) =>
              place.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw 'Failed to search places: $e';
    }
  }
}
