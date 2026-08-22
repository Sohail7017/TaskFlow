import '../entities/organization.dart';

/// Contract for organization data operations
abstract interface class OrganizationRepository {
  /// Fetch all organizations
  Future<List<Organization>> getOrganizations();

  /// Fetch a specific organization by ID
  Future<Organization?> getOrganizationById(String id);
}
