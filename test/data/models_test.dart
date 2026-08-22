import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/data/models/auth_credentials_model.dart';
import 'package:task_flow/data/models/comment_model.dart';
import 'package:task_flow/data/models/mock_login_response_model.dart';
import 'package:task_flow/data/models/notification_model.dart';
import 'package:task_flow/data/models/org_member_model.dart';
import 'package:task_flow/data/models/organization_model.dart';
import 'package:task_flow/data/models/project_model.dart';
import 'package:task_flow/data/models/task_model.dart';
import 'package:task_flow/data/models/user_model.dart';
import 'package:task_flow/domain/entities/enums.dart';

void main() {
  group('Enums definition', () {
    test('Enums have correct values', () {
      expect(OrgRole.values, [OrgRole.orgAdmin, OrgRole.member]);
      expect(TaskStatus.values, [
        TaskStatus.todo,
        TaskStatus.inProgress,
        TaskStatus.review,
        TaskStatus.done,
      ]);
      expect(TaskPriority.values, [
        TaskPriority.low,
        TaskPriority.medium,
        TaskPriority.high,
        TaskPriority.urgent,
      ]);
    });
  });

  group('Models JSON serialization & deserialization', () {
    test('OrganizationModel fromJson and toJson', () {
      final json = {
        'id': 'org_1',
        'name': 'Test Org',
        'created_at': '2025-11-02T09:15:00.000Z',
      };

      final model = OrganizationModel.fromJson(json);
      expect(model.id, 'org_1');
      expect(model.name, 'Test Org');
      expect(model.createdAt, DateTime.parse('2025-11-02T09:15:00.000Z'));

      final outJson = model.toJson();
      expect(outJson['id'], 'org_1');
      expect(outJson['name'], 'Test Org');
      expect(outJson['created_at'], '2025-11-02T09:15:00.000Z');
    });

    test('UserModel fromJson and toJson', () {
      final json = {
        'id': 'user_1',
        'name': 'Ava Thompson',
        'email': 'ava@test.com',
        'avatar_url': 'https://example.com/avatar.jpg',
      };

      final model = UserModel.fromJson(json);
      expect(model.id, 'user_1');
      expect(model.name, 'Ava Thompson');
      expect(model.email, 'ava@test.com');
      expect(model.avatarUrl, 'https://example.com/avatar.jpg');

      final outJson = model.toJson();
      expect(outJson['id'], 'user_1');
      expect(outJson['avatar_url'], 'https://example.com/avatar.jpg');
    });

    test('OrgMemberModel fromJson and toJson', () {
      final json = {
        'org_id': 'org_1',
        'user_id': 'user_1',
        'role': 'org_admin',
      };

      final model = OrgMemberModel.fromJson(json);
      expect(model.orgId, 'org_1');
      expect(model.userId, 'user_1');
      expect(model.role, OrgRole.orgAdmin);

      final outJson = model.toJson();
      expect(outJson['org_id'], 'org_1');
      expect(outJson['user_id'], 'user_1');
      expect(outJson['role'], 'org_admin');
    });

    test('ProjectModel fromJson and toJson', () {
      final json = {
        'id': 'proj_1',
        'org_id': 'org_1',
        'name': 'Website Relaunch',
        'description': 'Marketing website rebuild',
        'task_count': 6,
        'status': 'active',
        'created_at': '2025-12-01T10:00:00.000Z',
      };

      final model = ProjectModel.fromJson(json);
      expect(model.id, 'proj_1');
      expect(model.orgId, 'org_1');
      expect(model.name, 'Website Relaunch');
      expect(model.taskCount, 6);
      expect(model.status, 'active');

      final outJson = model.toJson();
      expect(outJson['task_count'], 6);
      expect(outJson['status'], 'active');
    });

    test('TaskModel fromJson and toJson with assigneeId and nullable assigneeId', () {
      final jsonWithAssignee = {
        'id': 'task_1',
        'project_id': 'proj_1',
        'title': 'Design Tokens',
        'description': 'Define tokens',
        'status': 'in_progress',
        'priority': 'high',
        'assignee_id': 'user_2',
        'due_date': '2026-01-05',
        'created_at': '2025-12-02T09:00:00.000Z',
      };

      final model1 = TaskModel.fromJson(jsonWithAssignee);
      expect(model1.id, 'task_1');
      expect(model1.status, TaskStatus.inProgress);
      expect(model1.priority, TaskPriority.high);
      expect(model1.assigneeId, 'user_2');
      expect(model1.dueDate, DateTime(2026, 1, 5));

      final jsonWithoutAssignee = {
        'id': 'task_2',
        'project_id': 'proj_1',
        'title': 'SEO audit',
        'description': 'Run technical audit',
        'status': 'todo',
        'priority': 'low',
        'assignee_id': null,
        'due_date': '2026-02-01',
        'created_at': '2025-12-12T09:00:00.000Z',
      };

      final model2 = TaskModel.fromJson(jsonWithoutAssignee);
      expect(model2.assigneeId, isNull);
      expect(model2.status, TaskStatus.todo);
      expect(model2.priority, TaskPriority.low);

      final outJson = model2.toJson();
      expect(outJson['assignee_id'], isNull);
      expect(outJson['due_date'], '2026-02-01');
    });

    test('CommentModel fromJson and toJson', () {
      final json = {
        'id': 'cmt_1',
        'task_id': 'task_1',
        'author_id': 'user_1',
        'body': 'Looks good!',
        'created_at': '2025-12-20T11:00:00.000Z',
      };

      final model = CommentModel.fromJson(json);
      expect(model.id, 'cmt_1');
      expect(model.taskId, 'task_1');
      expect(model.authorId, 'user_1');
      expect(model.body, 'Looks good!');

      final outJson = model.toJson();
      expect(outJson['id'], 'cmt_1');
      expect(outJson['body'], 'Looks good!');
    });

    test('NotificationModel fromJson and toJson', () {
      final json = {
        'id': 'notif_1',
        'user_id': 'user_2',
        'type': 'task_assigned',
        'task_id': 'task_1',
        'message': 'You were assigned to task 1',
        'read': false,
        'created_at': '2025-12-10T09:05:00.000Z',
      };

      final model = NotificationModel.fromJson(json);
      expect(model.id, 'notif_1');
      expect(model.userId, 'user_2');
      expect(model.type, 'task_assigned');
      expect(model.read, isFalse);

      final outJson = model.toJson();
      expect(outJson['type'], 'task_assigned');
      expect(outJson['read'], isFalse);
    });

    test('AuthCredentialsModel fromJson and toJson', () {
      final json = {
        'email': 'ava.admin@nimbusdigital.test',
        'password': 'Password123!',
        'org_id': 'org_a1b2c3',
        'role': 'org_admin',
      };

      final model = AuthCredentialsModel.fromJson(json);
      expect(model.email, 'ava.admin@nimbusdigital.test');
      expect(model.password, 'Password123!');
      expect(model.orgId, 'org_a1b2c3');
      expect(model.role, OrgRole.orgAdmin);

      final outJson = model.toJson();
      expect(outJson['role'], 'org_admin');
    });

    test('MockLoginResponseModel fromJson and toJson', () {
      final json = {
        'access_token': 'mock.access.token.short_lived',
        'refresh_token': 'mock.refresh.token.long_lived',
        'access_token_expires_in_seconds': 900,
        'refresh_token_expires_in_seconds': 604800,
      };

      final model = MockLoginResponseModel.fromJson(json);
      expect(model.accessToken, 'mock.access.token.short_lived');
      expect(model.refreshToken, 'mock.refresh.token.long_lived');
      expect(model.accessTokenExpiresInSeconds, 900);
      expect(model.refreshTokenExpiresInSeconds, 604800);

      final outJson = model.toJson();
      expect(outJson['access_token_expires_in_seconds'], 900);
      expect(outJson['refresh_token_expires_in_seconds'], 604800);
    });
  });
}
