import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property.dart';
import '../services/property_service.dart';

// Filter state
class PropertyFilter {
  final String? purpose;
  final String? type;
  final String? governorate;
  final String? searchQuery;
  final bool? isSold;

  const PropertyFilter({
    this.purpose,
    this.type,
    this.governorate,
    this.searchQuery,
    this.isSold,
  });

  PropertyFilter copyWith({
    String? purpose,
    String? type,
    String? governorate,
    String? searchQuery,
    bool? isSold,
    bool clearPurpose = false,
    bool clearType = false,
    bool clearGovernorate = false,
    bool clearSearch = false,
  }) {
    return PropertyFilter(
      purpose: clearPurpose ? null : (purpose ?? this.purpose),
      type: clearType ? null : (type ?? this.type),
      governorate: clearGovernorate ? null : (governorate ?? this.governorate),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      isSold: isSold ?? this.isSold,
    );
  }

  bool get hasActiveFilters =>
      purpose != null || type != null || governorate != null || isSold != null;

  PropertyFilter clear() => const PropertyFilter();
}

// Property list state
class PropertyListState {
  final List<Property> properties;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final PropertyFilter filter;
  final String? error;

  const PropertyListState({
    this.properties = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
    this.filter = const PropertyFilter(),
    this.error,
  });

  PropertyListState copyWith({
    List<Property>? properties,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    PropertyFilter? filter,
    String? error,
  }) {
    return PropertyListState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      filter: filter ?? this.filter,
      error: error,
    );
  }
}

// Property list notifier
class PropertyListNotifier extends StateNotifier<PropertyListState> {
  PropertyListNotifier() : super(const PropertyListState()) {
    loadProperties();
  }

  Future<void> loadProperties() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final properties = await PropertyService.getProperties(
        page: 0,
        searchQuery: state.filter.searchQuery,
        purpose: state.filter.purpose,
        type: state.filter.type,
        governorate: state.filter.governorate,
        isSold: state.filter.isSold,
      );
      state = state.copyWith(
        properties: properties,
        isLoading: false,
        page: 0,
        hasMore: properties.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final more = await PropertyService.getProperties(
        page: nextPage,
        searchQuery: state.filter.searchQuery,
        purpose: state.filter.purpose,
        type: state.filter.type,
        governorate: state.filter.governorate,
        isSold: state.filter.isSold,
      );
      state = state.copyWith(
        properties: [...state.properties, ...more],
        isLoadingMore: false,
        page: nextPage,
        hasMore: more.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void updateFilter(PropertyFilter filter) {
    state = state.copyWith(filter: filter);
    loadProperties();
  }

  void search(String query) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        searchQuery: query.isEmpty ? null : query,
        clearSearch: query.isEmpty,
      ),
    );
    loadProperties();
  }

  void clearFilters() {
    state = state.copyWith(filter: const PropertyFilter());
    loadProperties();
  }

  Future<void> refresh() => loadProperties();

  void removeProperty(String id) {
    state = state.copyWith(
      properties: state.properties.where((p) => p.id != id).toList(),
    );
  }
}

// Providers
final propertyListProvider =
    StateNotifierProvider<PropertyListNotifier, PropertyListState>((ref) {
  return PropertyListNotifier();
});

// Single property provider
final propertyDetailProvider =
    FutureProvider.family<Property?, String>((ref, id) async {
  return PropertyService.getProperty(id);
});
