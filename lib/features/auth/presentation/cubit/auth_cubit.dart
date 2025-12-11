import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serfix/features/auth/domain/entities/app_user.dart';
import 'package:serfix/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_auth_state.dart';

class AuthCubit extends Cubit<UserAuthState> {
  final AuthRepository authRepository;
  AppUser? _currentUser;
  late final StreamSubscription<AppUser?> _authStateSubscription;

  AuthCubit({required this.authRepository}) : super(AuthInitial()) {
    _authStateSubscription = authRepository.authStateChanges.listen(
      (AppUser? user) {
        if (user != null) {
          _currentUser = user;
          emit(AuthAuthenticated(user: user));
        } else {
          _currentUser = null;
          emit(AuthUnauthenticated());
        }
      },
      onError: (error) {
        emit(AuthError(message: 'Authentication stream error: $error'));
      },
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }

  AppUser? get currentUser => _currentUser;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final AppUser? user = await authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      if (user != null) {
        _currentUser = user;
      } else {
        emit(AuthUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthError(message: 'Authentication error: ${e.message}'));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String fullName,
    String? licenseNumber,
  }) async {
    try {
      emit(AuthLoading());
      await authRepository.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        licenseNumber: licenseNumber,
      );
    } on AuthException catch (e) {
      emit(AuthError(message: 'Signup error: ${e.message}'));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Failed to sign out: ${e.toString()}'));
    }
  }
}
