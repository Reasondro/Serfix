import 'package:serfix/features/auth/domain/entities/app_user.dart';
import 'package:serfix/features/auth/domain/entities/user_role.dart';
import 'package:serfix/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  AppUser? _mapSupabaseUserToAppUser({User? supabaseUser}) {
    if (supabaseUser == null) {
      return null;
    }
    try {
      final Map<String, dynamic> userData = {
        'id': supabaseUser.id,
        'email': supabaseUser.email,
        'user_metadata': supabaseUser.userMetadata ?? {},
      };
      return AppUser.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return supabase.auth.onAuthStateChange
        .map((AuthState authState) {
          final User? supabaseUser = authState.session?.user;
          return _mapSupabaseUserToAppUser(supabaseUser: supabaseUser);
        })
        .handleError((error) {
          return null;
        });
  }

  @override
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return _mapSupabaseUserToAppUser(supabaseUser: authResponse.user);
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  @override
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String fullName,
    String? licenseNumber,
  }) async {
    try {
      final Map<String, dynamic> userMetadata = {
        'username': username,
        'full_name': fullName,
        'role': UserRole.doctor.name,
        'license_number': licenseNumber,
      };

      final AuthResponse authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: userMetadata,
      );

      return _mapSupabaseUserToAppUser(supabaseUser: authResponse.user);
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final User? supabaseUser = supabase.auth.currentUser;
    return _mapSupabaseUserToAppUser(supabaseUser: supabaseUser);
  }
}
