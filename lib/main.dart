import 'package:flutter/material.dart';
import 'package:attendance_system/app.dart';
import 'package:attendance_system/core/di/injection.dart';
import 'package:attendance_system/features/user/domain/usecases/login_usecase.dart';
import 'package:attendance_system/features/user/domain/usecases/get_current_user_usecase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DI
  await initDependencies();

  // Resolve usecases to verify DI wiring (we won't call network operations here).
  // final LoginUseCase loginUseCase = resolve<LoginUseCase>();
  // final GetCurrentUserUseCase getCurrentUserUseCase =
  //     resolve<GetCurrentUserUseCase>();

  // await loginUseCase.call("admin@attendancesystem.com", "12345678aA@");
  // var currentUser = await getCurrentUserUseCase.call();
  // // print debug info
  // debugPrint('Current User: ${currentUser?.toString()}');

  runApp(const MyApp());
}
