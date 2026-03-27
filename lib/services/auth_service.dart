import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  /// Get current session
  static Session? get currentSession => _supabase.auth.currentSession;

  /// Get current user
  static User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Check if phone exists (via edge function)
  static Future<Map<String, dynamic>> checkPhone(String phone, String mode) async {
    try {
      final response = await _supabase.functions.invoke(
        'check-phone',
        body: {'phone': phone, 'mode': mode},
      );
      if (response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return {'allowed': true};
    } catch (e) {
      debugPrint('Error checking phone: $e');
      return {'allowed': true}; // Fail open
    }
  }

  /// Send OTP to phone number
  static Future<void> sendOtp(String phone) async {
    final formattedPhone = _formatPhone(phone);
    await _supabase.auth.signInWithOtp(phone: formattedPhone);
  }

  /// Verify OTP code
  static Future<AuthResponse> verifyOtp(String phone, String code) async {
    final formattedPhone = _formatPhone(phone);
    return await _supabase.auth.verifyOTP(
      phone: formattedPhone,
      token: code,
      type: OtpType.sms,
    );
  }

  /// Get user profile from profiles table
  static Future<UserProfile?> getProfile() async {
    if (currentUser == null) return null;
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();
      if (data != null) {
        return UserProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  /// Create or update user profile
  static Future<UserProfile?> upsertProfile({
    required String name,
    String? phone,
    String? companyName,
    String? accountType,
  }) async {
    if (currentUser == null) return null;
    try {
      final data = {
        'id': currentUser!.id,
        'name': name,
        'phone': phone ?? currentUser!.phone,
        'company_name': companyName,
        'account_type': accountType,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final result = await _supabase
          .from('profiles')
          .upsert(data)
          .select()
          .single();

      return UserProfile.fromJson(result);
    } catch (e) {
      debugPrint('Error upserting profile: $e');
      return null;
    }
  }

  /// Update profile fields
  static Future<UserProfile?> updateProfile(Map<String, dynamic> updates) async {
    if (currentUser == null) return null;
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      final result = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', currentUser!.id)
          .select()
          .single();
      return UserProfile.fromJson(result);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return null;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Format phone number with country code
  static String _formatPhone(String phone) {
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!phone.startsWith('+')) {
      if (phone.startsWith('0')) {
        phone = phone.substring(1);
      }
      phone = '${AppConstants.countryCode}$phone';
    }
    return phone;
  }
}
