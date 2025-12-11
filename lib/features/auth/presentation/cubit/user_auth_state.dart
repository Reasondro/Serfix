part of 'auth_cubit.dart';

sealed class UserAuthState extends Equatable {
  const UserAuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends UserAuthState {}

final class AuthLoading extends UserAuthState {}

final class AuthAuthenticated extends UserAuthState {
  final AppUser user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends UserAuthState {}

final class AuthError extends UserAuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
