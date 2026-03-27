import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property.dart';
import '../services/favorites_service.dart';
import 'auth_provider.dart';

// Favorites state
class FavoritesState {
  final Set<String> favoriteIds;
  final List<Property> favoriteProperties;
  final bool isLoading;

  const FavoritesState({
    this.favoriteIds = const {},
    this.favoriteProperties = const [],
    this.isLoading = false,
  });

  FavoritesState copyWith({
    Set<String>? favoriteIds,
    List<Property>? favoriteProperties,
    bool? isLoading,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      favoriteProperties: favoriteProperties ?? this.favoriteProperties,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool isFavorite(String propertyId) => favoriteIds.contains(propertyId);
}

// Favorites notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final Ref _ref;

  FavoritesNotifier(this._ref) : super(const FavoritesState()) {
    _init();
  }

  void _init() {
    final authState = _ref.read(authProvider);
    if (authState.isLoggedIn && authState.user != null) {
      loadFavorites(authState.user!.id);
    }
  }

  Future<void> loadFavorites(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final ids = await FavoritesService.getFavoriteIds(userId);
      final properties = await FavoritesService.getFavoriteProperties(userId);
      state = state.copyWith(
        favoriteIds: ids,
        favoriteProperties: properties,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleFavorite(String propertyId) async {
    final authState = _ref.read(authProvider);
    if (!authState.isLoggedIn || authState.user == null) return;

    final userId = authState.user!.id;
    final isFav = state.isFavorite(propertyId);

    // Optimistic update
    final newIds = Set<String>.from(state.favoriteIds);
    if (isFav) {
      newIds.remove(propertyId);
    } else {
      newIds.add(propertyId);
    }
    state = state.copyWith(favoriteIds: newIds);

    // Server update
    final success = await FavoritesService.toggleFavorite(userId, propertyId, isFav);
    if (!success) {
      // Revert on failure
      final revertIds = Set<String>.from(state.favoriteIds);
      if (isFav) {
        revertIds.add(propertyId);
      } else {
        revertIds.remove(propertyId);
      }
      state = state.copyWith(favoriteIds: revertIds);
    } else {
      // Reload full list
      loadFavorites(userId);
    }
  }

  Future<void> refresh() async {
    final authState = _ref.read(authProvider);
    if (authState.isLoggedIn && authState.user != null) {
      await loadFavorites(authState.user!.id);
    }
  }
}

// Provider
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref);
});
