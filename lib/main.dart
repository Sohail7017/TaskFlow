import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator and core dependencies
  await initDependencies();

  runApp(const TaskFlowApp());
}
