import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/app.dart';
import 'package:task_flow/core/di/injection.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('task_flow_test_');
    await sl.reset();
    await initDependencies(hiveStoragePath: tempDir.path);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('TaskFlowApp builds and displays initial setup screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle();

    expect(find.text('TaskFlow'), findsWidgets);
  });
}
