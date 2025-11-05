import 'package:flutter/material.dart';
import 'package:attendance_system/app.dart';
import 'package:attendance_system/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}
