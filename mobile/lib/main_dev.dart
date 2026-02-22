import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.setEnvironment(Environment.dev);

  runApp(
    const ProviderScope(
      child: TulipApp(),
    ),
  );
}
