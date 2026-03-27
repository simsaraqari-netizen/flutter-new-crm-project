import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user_profile.dart';
import '../services/auth_service.dart';

// Auth status enum
enum AuthStatus { initial, authenticated, unauthenticated, loading }

// Auth state class
class AppAuthState {
  final AuthStatus status;
  final sb.User? user;
  final UserProfile? profile;
  final String? error;

  const AppAuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.profile,
    this.error,
  });

  AppAuthState copyWith({
    AuthStatus? status,
    sb.User? user,
    UserProfile? profile,
    String? error,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      error: error,
    );
  }

  bool get isLoggedIn => status == AuthStatus.authenticated;
}

// Auth notifier
class AuthNotifier extends StateNotifier<AppAuthState> {
  StreamSubscription? _authSub;

  AuthNotifier() : super(const AppAuthState()) {
    _init();
  }

  void _init() {
    // Check initial session
    final session = AuthService.currentSession;
    if (session != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: AuthService.currentUser,
      );
      _loadProfile();
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    // Listen to auth changes
    _authSub = AuthService.authStateChanges.listen((event) {
      if (event.session != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: event.session!.user,
        );
        _loadProfile();
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          profile: null,
        );
      }
    });
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getProfile();
    if (profile != null) {
      state = state.copyWith(profile: profile);
    }
  }

  Future<Map<String, dynamic>> checkPhone(String phone, String mode) async {
    return AuthService.checkPhone(phone, mode);
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await AuthService.sendOtp(phone);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> verifyOtp(String phone, String code) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await AuthService.verifyOtp(phone, code);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> createProfile({
    required String name,
    String? phone,
    String? companyName,
  }) async {
    final profile = await AuthService.upsertProfile(
      name: name,
      phone: phone,
      companyName: companyName,
    );
    if (profile != null) {
      state = state.copyWith(profile: profile);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final profile = await AuthService.updateProfile(updates);
    if (profile != null) {
      state = state.copyWith(profile: profile);
    }
  }

  Future<void> refreshProfile() => _loadProfile();

  Future<void> signOut() async {
    await AuthService.signOut();
    state = const AppAuthState(status: AuthStatus.unauthenticated);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier();
});
