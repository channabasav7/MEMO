import 'package:favoriteplaces/data/fav_placedata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifier, StateNotifierProvider;

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
