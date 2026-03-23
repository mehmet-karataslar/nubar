import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/shared/services/supabase_service.dart';

class CurrentUserProfile {
  CurrentUserProfile._();

  static Future<String> getOrCreateId() async {
    final authUser = SupabaseService.currentUser;
    if (authUser == null) {
      throw Exception('Not authenticated');
    }

    final existing = await SupabaseService.from(
      SupabaseConstants.usersTable,
    ).select('id').eq('auth_id', authUser.id).maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    final username = _buildUsername(authUser.email, authUser.id);
    final fullName = _buildFullName(authUser.email);

    await SupabaseService.from(SupabaseConstants.usersTable).insert({
      'auth_id': authUser.id,
      'username': username,
      'full_name': fullName,
      'preferred_lang': 'ku',
    });

    final created = await SupabaseService.from(
      SupabaseConstants.usersTable,
    ).select('id').eq('auth_id', authUser.id).maybeSingle();

    if (created == null) {
      throw Exception('User profile could not be initialized.');
    }

    return created['id'] as String;
  }

  static String _buildUsername(String? email, String authId) {
    final base = (email ?? 'user')
        .split('@')
        .first
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final safeBase = base.isEmpty ? 'user' : base;
    final shortId = authId.replaceAll('-', '').substring(0, 6);
    return '${safeBase}_$shortId';
  }

  static String _buildFullName(String? email) {
    if (email == null || email.isEmpty) return 'Nubar User';
    return email.split('@').first;
  }
}
