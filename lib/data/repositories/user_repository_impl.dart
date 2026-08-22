import '../../domain/entities/org_member.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/mock_data_source.dart';

/// Concrete implementation of [UserRepository] backed by [MockDataSource]
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({
    required this.mockDataSource,
  });

  final MockDataSource mockDataSource;

  @override
  Future<List<User>> getUsers() async {
    return mockDataSource.getUsers();
  }

  @override
  Future<User?> getUserById(String id) async {
    final users = await mockDataSource.getUsers();
    for (final user in users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }

  @override
  Future<List<OrgMember>> getOrgMembers() async {
    return mockDataSource.getOrgMembers();
  }

  @override
  Future<List<OrgMember>> getMembersByOrgId(String orgId) async {
    final members = await mockDataSource.getOrgMembers();
    return members.where((m) => m.orgId == orgId).toList();
  }

  @override
  Future<List<User>> getUsersByOrgId(String orgId) async {
    final members = await getMembersByOrgId(orgId);
    final userIds = members.map((m) => m.userId).toSet();
    final allUsers = await mockDataSource.getUsers();
    return allUsers.where((u) => userIds.contains(u.id)).toList();
  }
}
