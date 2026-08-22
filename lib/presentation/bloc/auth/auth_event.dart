import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to check if an active session exists in secure storage
class SessionCheckRequested extends AuthEvent {
  const SessionCheckRequested();
}

/// Dispatched when the user submits their login credentials
class LoginRequested extends AuthEvent {
  const LoginRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Dispatched when the user initiates logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Dispatched to refresh an expired access token using a refresh token
class RefreshTokenRequested extends AuthEvent {
  const RefreshTokenRequested({required this.refreshToken});

  final String refreshToken;

  @override
  List<Object?> get props => [refreshToken];
}
