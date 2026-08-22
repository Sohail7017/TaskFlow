import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';
import '../datasources/mock_data_source.dart';

/// Concrete implementation of [OrganizationRepository] backed by [MockDataSource]
class OrganizationRepositoryImpl implements OrganizationRepository {
  const OrganizationRepositoryImpl({
    required this.mockDataSource,
  });

  final MockDataSource mockDataSource;

  @override
  Future<List<Organization>> getOrganizations() async {
    return mockDataSource.getOrganizations();
  }

  @override
  Future<Organization?> getOrganizationById(String id) async {
    final list = await mockDataSource.getOrganizations();
    for (final org in list) {
      if (org.id == id) {
        return org;
      }
    }
    return null;
  }
}
