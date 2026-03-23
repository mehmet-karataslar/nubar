import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/features/auth/models/auth_model.dart';
import 'package:nubar/shared/services/supabase_service.dart';

// Auth state
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.auth.onAuthStateChange;
});

// Current user profile
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final state = authState.valueOrNull;
  if (state == null) return null;
  final user = state.session?.user;
  if (user == null) return null;

  final response = await SupabaseService.from(
    SupabaseConstants.usersTable,
  ).select().eq('auth_id', user.id).maybeSingle();

  if (response == null) return null;
  return UserModel.fromJson(response);
});

// Auth notifier for login/register/logout actions
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
      return AuthNotifier(ref);
    });

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(Ref ref) : super(const AsyncValue.data(null));

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SupabaseService.signIn(email: email, password: password);
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
    String preferredLang = 'ku',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authResponse = await SupabaseService.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        await SupabaseService.from(SupabaseConstants.usersTable).insert({
          'auth_id': authResponse.user!.id,
          'username': username,
          'full_name': fullName,
          'preferred_lang': preferredLang,
        });
      }
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SupabaseService.signOut();
    });
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SupabaseService.resetPassword(email);
    });
  }
}
