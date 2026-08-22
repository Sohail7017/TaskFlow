import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/enums.dart';

/// Data model for [AuthCredentials]
class AuthCredentialsModel extends AuthCredentials {
  const AuthCredentialsModel({
    required super.email,
    required super.password,
    required super.orgId,
    required super.role,
  });

  factory AuthCredentialsModel.fromJson(Map<String, dynamic> json) {
    return AuthCredentialsModel(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      orgId: json['org_id'] as String? ?? '',
      role: _parseOrgRole(json['role'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'org_id': orgId,
      'role': role == OrgRole.orgAdmin ? 'org_admin' : 'member',
    };
  }

  static OrgRole _parseOrgRole(String? role) {
    switch (role) {
      case 'org_admin':
        return OrgRole.orgAdmin;
      default:
        return OrgRole.member;
    }
  }
}
