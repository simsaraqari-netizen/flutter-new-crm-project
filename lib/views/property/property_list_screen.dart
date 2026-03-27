import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/property_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/property_card.dart';
import '../../widgets/search_filter_bar.dart';
import '../../widgets/loading_shimmer.dart';
import '../../utils/theme.dart';
import '../property/property_detail_screen.dart';
import '../property/property_form_screen.dart';

class PropertyListScreen extends ConsumerStatefulWidget {
  const PropertyListScreen({super.key});

  @override
  ConsumerState<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends ConsumerState<PropertyListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(propertyListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyListProvider);
    final favState = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سمسار عقاري',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'اعثر على عقارك المثالي',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Property count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.properties.length}+',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Search & Filter
            SearchFilterBar(
              initialQuery: state.filter.searchQuery,
              selectedPurpose: state.filter.purpose,
              selectedType: state.filter.type,
              selectedGovernorate: state.filter.governorate,
              onSearch: (query) {
                ref.read(propertyListProvider.notifier).search(query);
              },
              onPurposeChanged: (v) {
                ref.read(propertyListProvider.notifier).updateFilter(
                      state.filter.copyWith(
                        purpose: v,
                        clearPurpose: v == null,
                      ),
                    );
              },
              onTypeChanged: (v) {
                ref.read(propertyListProvider.notifier).updateFilter(
                      state.filter.copyWith(
                        type: v,
                        clearType: v == null,
                      ),
                    );
              },
              onGovernorateChanged: (v) {
                ref.read(propertyListProvider.notifier).updateFilter(
                      state.filter.copyWith(
                        governorate: v,
                        clearGovernorate: v == null,
                      ),
                    );
              },
              onClearAll: () {
                ref.read(propertyListProvider.notifier).clearFilters();
              },
            ),

            const SizedBox(height: 8),

            // Property list
            Expanded(
              child: state.isLoading
                  ? const LoadingShimmer()
                  : state.properties.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: AppTheme.primaryBlue,
                          backgroundColor: AppTheme.surfaceCard,
                          onRefresh: () => ref.read(propertyListProvider.notifier).refresh(),
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: state.properties.length + (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.properties.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                );
                              }

                              final property = state.properties[index];
                              return PropertyCard(
                                property: property,
                                isFavorite: favState.isFavorite(property.id),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PropertyDetailScreen(
                                        property: property,
                                      ),
                                    ),
                                  );
                                },
                                onFavoriteToggle: () {
                                  ref.read(favoritesProvider.notifier).toggleFavorite(property.id);
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PropertyFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppTheme.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد نتائج',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'جرّب تغيير عبارة البحث أو الفلاتر',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
