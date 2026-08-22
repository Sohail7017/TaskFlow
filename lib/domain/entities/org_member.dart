import 'enums.dart';

/// Organization membership domain entity
class OrgMember {
  const OrgMember({
    required this.orgId,
    required this.userId,
    required this.role,
  });

  final String orgId;
  final String userId;
  final OrgRole role;
}
