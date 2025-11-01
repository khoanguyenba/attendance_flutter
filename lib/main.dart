import 'package:attendance_system/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:attendance_system/features/auth/data/repositories/user_repository_impl.dart';
import 'package:dio/dio.dart' show Dio;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:attendance_system/firebase_options.dart';
import 'package:attendance_system/app.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());

  var userRepository = UserRepositoryImpl(
    UserRemoteDataSourceImpl(Dio(), FlutterSecureStorage()),
  );

  await userRepository.login("admin@attendancesystem.com", "12345678aA@");
}
