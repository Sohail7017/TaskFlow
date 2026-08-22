import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/data/datasources/mock_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDataSource dataSource;

  setUp(() {
    dataSource = MockDataSource();
  });

  group('MockDataSource initialization and parsing', () {
    test('loads and caches all mock collections with exact counts', () async {
      await dataSource.loadMockData();

      final organizations = await dataSource.getOrganizations();
      final users = await dataSource.getUsers();
      final orgMembers = await dataSource.getOrgMembers();
      final projects = await dataSource.getProjects();
      final tasks = await dataSource.getTasks();
      final comments = await dataSource.getComments();
      final notifications = await dataSource.getNotifications();
      final authCredentials = await dataSource.getAuthCredentials();
      final loginResponse = await dataSource.getMockLoginResponse();

      // Verify exact collection counts
      expect(organizations.length, 2);
      expect(users.length, 5);
      expect(orgMembers.length, 5);
      expect(projects.length, 3);
      expect(tasks.length, 15);
      expect(comments.length, 4);
      expect(notifications.length, 3);
      expect(authCredentials.length, 4);

      // Verify sample data properties
      expect(organizations.first.name, 'Nimbus Digital');
      expect(users.first.name, 'Ava Thompson');
      expect(projects.first.name, 'Website Relaunch');
      expect(tasks.first.title, 'Set up design tokens in Figma');
      expect(loginResponse.accessToken, 'mock.access.token.short_lived');
    });

    test('getters automatically trigger loadMockData when not loaded', () async {
      final freshDataSource = MockDataSource();
      final projects = await freshDataSource.getProjects();
      expect(projects.length, 3);
    });
  });
}
