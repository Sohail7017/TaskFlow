import '../../domain/entities/enums.dart';
import '../../domain/entities/org_member.dart';

/// Data model for [OrgMember]
class OrgMemberModel extends OrgMember {
  const OrgMemberModel({
    required super.orgId,
    required super.userId,
    required super.role,
  });

  factory OrgMemberModel.fromJson(Map<String, dynamic> json) {
    return OrgMemberModel(
      orgId: json['org_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      role: _parseOrgRole(json['role'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'org_id': orgId,
      'user_id': userId,
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
