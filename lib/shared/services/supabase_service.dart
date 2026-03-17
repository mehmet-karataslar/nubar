import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  // Auth
  static GoTrueClient get auth => client.auth;
  static User? get currentUser => auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await auth.resetPasswordForEmail(email);
  }

  // Database queries
  static SupabaseQueryBuilder from(String table) => client.from(table);

  // Edge functions
  static Future<FunctionResponse> invokeFunction(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    return await client.functions.invoke(
      functionName,
      body: body,
    );
  }

  // Realtime
  static RealtimeChannel channel(String name) => client.channel(name);
}
