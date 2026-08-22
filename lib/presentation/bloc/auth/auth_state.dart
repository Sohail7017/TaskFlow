import 'package:equatable/equatable.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/user.dart';

/// Enum representing the possible statuses of authentication
enum AuthStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

/// Unified authentication state using status-based approach.
/// Preserves session information by reusing [User], [OrgRole], and [orgId].
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.user,
    this.orgId,
    this.role,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? token;
  final User? user;
  final String? orgId;
  final OrgRole? role;
  final String? errorMessage;

  /// Convenience factory for the initial state
  factory AuthState.initial() => const AuthState();

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    User? user,
    String? orgId,
    OrgRole? role,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      user: user ?? this.user,
      orgId: orgId ?? this.orgId,
      role: role ?? this.role,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, token, user, orgId, role, errorMessage];
}
