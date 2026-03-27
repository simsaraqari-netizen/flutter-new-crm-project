import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property.dart';

class FavoritesService {
  static final _supabase = Supabase.instance.client;

  /// Get user's favorite property IDs
  static Future<Set<String>> getFavoriteIds(String userId) async {
    try {
      final data = await _supabase
          .from('favorites')
          .select('property_id')
          .eq('user_id', userId);
      return (data as List)
          .map((e) => e['property_id'] as String)
          .toSet();
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      return {};
    }
  }

  /// Get user's favorite properties with full details
  static Future<List<Property>> getFavoriteProperties(String userId) async {
    try {
      final data = await _supabase
          .from('favorites')
          .select('property_id, properties(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (data as List)
          .where((e) => e['properties'] != null)
          .map((e) => Property.fromJson(e['properties']))
          .toList();
    } catch (e) {
      debugPrint('Error fetching favorite properties: $e');
      return [];
    }
  }

  /// Add property to favorites
  static Future<bool> addFavorite(String userId, String propertyId) async {
    try {
      await _supabase.from('favorites').upsert({
        'user_id': userId,
        'property_id': propertyId,
      });
      return true;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    }
  }

  /// Remove property from favorites
  static Future<bool> removeFavorite(String userId, String propertyId) async {
    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('property_id', propertyId);
      return true;
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      return false;
    }
  }

  /// Toggle favorite status
  static Future<bool> toggleFavorite(String userId, String propertyId, bool isFavorite) async {
    if (isFavorite) {
      return removeFavorite(userId, propertyId);
    } else {
      return addFavorite(userId, propertyId);
    }
  }
}
