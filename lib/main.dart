import 'package:flutter/material.dart';

import 'app/app_dependencies.dart';
import 'app/hapy_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = await AppDependencies.create();
  runApp(HapyApp(deps: deps));
}
