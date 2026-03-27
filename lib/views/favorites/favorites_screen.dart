import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/property_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../utils/theme.dart';
import '../property/property_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المفضلة',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'العقارات المحفوظة لديك',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: favState.isLoading
                  ? const LoadingShimmer(itemCount: 3)
                  : favState.favoriteProperties.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: AppTheme.primaryBlue,
                          backgroundColor: AppTheme.surfaceCard,
                          onRefresh: () => ref.read(favoritesProvider.notifier).refresh(),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: favState.favoriteProperties.length,
                            itemBuilder: (context, index) {
                              final property = favState.favoriteProperties[index];
                              return PropertyCard(
                                property: property,
                                isFavorite: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PropertyDetailScreen(property: property),
                                    ),
                                  );
                                },
                                onFavoriteToggle: () {
                                  ref
                                      .read(favoritesProvider.notifier)
                                      .toggleFavorite(property.id);
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: AppTheme.textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد عقارات مفضلة',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اضغط على ❤️ لحفظ العقارات المفضلة',
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
