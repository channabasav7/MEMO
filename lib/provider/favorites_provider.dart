import 'package:favoriteplaces/data/fav_placedata.dart';
import 'package:favoriteplaces/firestore_service.dart';
import 'package:favoriteplaces/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Firestore Service Provider
final firestoreServiceProvider = Provider((ref) => FirestoreService());

// Favorites State
class FavoritesState {
  final List<FavPlace> places;
  final bool isLoading;
  final String? error;

  FavoritesState({
    this.places = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<FavPlace>? places,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      places: places ?? this.places,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FirestoreService _firestoreService;
  final String _userId;

  FavoritesNotifier(
    this._firestoreService,
    this._userId,
  ) : super(FavoritesState()) {
    _loadPlaces();
  }

  void _loadPlaces() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final places = await _firestoreService.getUserPlaces(_userId);
      state = state.copyWith(places: places, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addPlace(FavPlace place) async {
    try {
      await _firestoreService.addPlace(_userId, place);
      _loadPlaces();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deletePlace(String docId) async {
    try {
      await _firestoreService.deletePlace(_userId, docId);
      state = state.copyWith(
        places: state.places
            .where((place) => place.docId != docId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updatePlace(String docId, FavPlace place) async {
    try {
      await _firestoreService.updatePlace(_userId, docId, place);
      _loadPlaces();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<List<FavPlace>> searchPlaces(String query) async {
    try {
      return await _firestoreService.searchPlaces(_userId, query);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

/// Favorites provider that depends on userId
final favoritesProvider =
    StateNotifierProvider.family<FavoritesNotifier, FavoritesState, String>(
  (ref, userId) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return FavoritesNotifier(firestoreService, userId);
  },
);

/// Stream provider for real-time favorites
final favoritesStreamProvider =
    StreamProvider.family<List<FavPlace>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserPlacesStream(userId);
});

/// Filtered favorites based on current auth state
final currentUserFavoritesProvider =
    StateNotifierProvider<FavPlaceProvider, List<FavPlace>>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    return FavPlaceProvider();
  }
  return FavPlaceProvider();
});

// Legacy provider for backward compatibility
class FavPlaceProvider extends StateNotifier<List<FavPlace>> {
  FavPlaceProvider() : super([]);

  void addPlace(FavPlace place) {
    state = [...state, place];
  }

  void removePlace(String id) {
    state = state.where((place) => place.id != id).toList();
  }

  List<FavPlace> getFavPlace() {
    return List.from(state);
  }
}

final favPlaceProvider =
    StateNotifierProvider<FavPlaceProvider, List<FavPlace>>(
      (ref) => FavPlaceProvider(),
    );
