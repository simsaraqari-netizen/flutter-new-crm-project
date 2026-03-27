import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property.dart';

class PropertyService {
  static final _supabase = Supabase.instance.client;

  static const int _pageSize = 20;

  /// Fetch properties with pagination, search, and filters
  static Future<List<Property>> getProperties({
    int page = 0,
    String? searchQuery,
    String? purpose,
    String? type,
    String? governorate,
    String? status,
    bool? isSold,
  }) async {
    try {
      var query = _supabase.from('properties').select();

      // Apply filters
      if (purpose != null && purpose.isNotEmpty) {
        query = query.eq('purpose', purpose);
      }
      if (type != null && type.isNotEmpty) {
        query = query.eq('type', type);
      }
      if (governorate != null && governorate.isNotEmpty) {
        query = query.eq('gov', governorate);
      }
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      if (isSold != null) {
        query = query.eq('is_sold', isSold);
      }

      // Apply search
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchQuery%,'
          'location.ilike.%$searchQuery%,'
          'phone.ilike.%$searchQuery%,'
          'seller.ilike.%$searchQuery%,'
          'details.ilike.%$searchQuery%,'
          'gov.ilike.%$searchQuery%,'
          'loc.ilike.%$searchQuery%',
        );
      }

      // Pagination
      final from = page * _pageSize;
      final to = from + _pageSize - 1;

      final data = await query.order('created_at', ascending: false).range(from, to);
      return (data as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching properties: $e');
      return [];
    }
  }

  /// Get single property by ID
  static Future<Property?> getProperty(String id) async {
    try {
      final data = await _supabase
          .from('properties')
          .select()
          .eq('id', id)
          .single();
      return Property.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching property: $e');
      return null;
    }
  }

  /// Create a new property
  static Future<Property?> createProperty(Property property) async {
    try {
      final data = await _supabase
          .from('properties')
          .insert(property.toJson())
          .select()
          .single();
      return Property.fromJson(data);
    } catch (e) {
      debugPrint('Error creating property: $e');
      return null;
    }
  }

  /// Update an existing property
  static Future<Property?> updateProperty(String id, Map<String, dynamic> updates) async {
    try {
      final data = await _supabase
          .from('properties')
          .update(updates)
          .eq('id', id)
          .select()
          .single();
      return Property.fromJson(data);
    } catch (e) {
      debugPrint('Error updating property: $e');
      return null;
    }
  }

  /// Delete a property
  static Future<bool> deleteProperty(String id) async {
    try {
      await _supabase.from('properties').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting property: $e');
      return false;
    }
  }

  /// Get total count of properties (with optional filters)
  static Future<int> getPropertyCount({
    String? purpose,
    String? type,
    String? governorate,
  }) async {
    try {
      var query = _supabase.from('properties').select('id');
      if (purpose != null) query = query.eq('purpose', purpose);
      if (type != null) query = query.eq('type', type);
      if (governorate != null) query = query.eq('gov', governorate);
      final data = await query;
      return (data as List).length;
    } catch (e) {
      debugPrint('Error counting properties: $e');
      return 0;
    }
  }

  /// Mark property as sold
  static Future<bool> markAsSold(String id, bool sold) async {
    try {
      await _supabase.from('properties').update({'is_sold': sold}).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error marking property: $e');
      return false;
    }
  }
}
