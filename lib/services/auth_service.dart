import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseService _supabaseService = SupabaseService();

  /// ===========================
  /// LOGIN
  /// ===========================
  Future<User?> login(String email, String password) async {
    try {
      final response = await _supabaseService.signIn(email, password);
      final user = response.user;

      if (user != null) {
        // Ambil role dari tabel users
        final userData = await Supabase.instance.client
            .from('users')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        // Simpan role ke metadata (bisa diakses di seluruh app)
        if (userData != null) {
          user.userMetadata?['role'] = userData['role'];
        }
      }

      return user;
    } on AuthApiException catch (e) {
      print('Login error: ${e.message}');
      rethrow;
    }
  }

  /// ===========================
  /// REGISTER
  /// ===========================
  Future<User?> register(String email, String password) async {
    try {
      final response = await _supabaseService.signUp(email, password);
      final user = response.user;

      if (user != null) {
        // Simpan ke tabel users Supabase dengan default role = 'customer'
        await Supabase.instance.client.from('users').insert({
          'id': user.id,
          'email': email,
          'role': 'customer',
        });
      }

      return user;
    } on AuthApiException catch (e) {
      print('Register error: ${e.message}');
      rethrow;
    }
  }

  /// ===========================
  /// LOGOUT
  /// ===========================
  Future<void> logout() async {
    await _supabaseService.signOut();
  }

  /// ===========================
  /// CURRENT USER
  /// ===========================
  User? get currentUser => _supabaseService.currentUser;
}
