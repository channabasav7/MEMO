import 'package:favoriteplaces/data/fav_placedata.dart';
import 'package:favoriteplaces/local_favorites_service.dart';
import 'package:favoriteplaces/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifier, StateNotifierProvider;

final localFavoritesServiceProvider = Provider((ref) => LocalFavoritesService());

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
  final LocalFavoritesService _localFavoritesService;
  final String _userId;

  FavoritesNotifier(
    this._localFavoritesService,
    this._userId,
  ) : super(FavoritesState()) {
    _loadPlaces();
  }

  void _loadPlaces() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final places = await _localFavoritesService.getUserPlaces(_userId);
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
      await _localFavoritesService.addPlace(_userId, place);
      _loadPlaces();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deletePlace(String docId) async {
    try {
      await _localFavoritesService.deletePlace(_userId, docId);
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
      await _localFavoritesService.updatePlace(_userId, docId, place);
      _loadPlaces();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<List<FavPlace>> searchPlaces(String query) async {
    try {
      return await _localFavoritesService.searchPlaces(_userId, query);
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
    final localFavoritesService = ref.watch(localFavoritesServiceProvider);
    return FavoritesNotifier(localFavoritesService, userId);
  },
);

final currentUserFavoritesProvider = Provider<List<FavPlace>>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    return const [];
  }
  return ref.watch(favoritesProvider(userId)).places;
});
