import 'package:serfix/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String fullName,
    String? licenseNumber,
  });

  Future<void> signOut();

  Future<AppUser?> getCurrentUser();

  Stream<AppUser?> get authStateChanges;
}
