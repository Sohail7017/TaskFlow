import 'enums.dart';

/// Test credentials domain entity
class AuthCredentials {
  const AuthCredentials({
    required this.email,
    required this.password,
    required this.orgId,
    required this.role,
  });

  final String email;
  final String password;
  final String orgId;
  final OrgRole role;
}
