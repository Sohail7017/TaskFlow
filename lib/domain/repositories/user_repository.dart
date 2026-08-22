import '../entities/org_member.dart';
import '../entities/user.dart';

/// Contract for user and organization membership data operations
abstract interface class UserRepository {
  /// Fetch all users
  Future<List<User>> getUsers();

  /// Fetch a specific user by ID
  Future<User?> getUserById(String id);

  /// Fetch all organization members
  Future<List<OrgMember>> getOrgMembers();

  /// Fetch organization members for a specific organization ID
  Future<List<OrgMember>> getMembersByOrgId(String orgId);

  /// Fetch user profiles belonging to a specific organization
  Future<List<User>> getUsersByOrgId(String orgId);
}
