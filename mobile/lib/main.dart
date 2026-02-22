import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment (can be changed for different build flavors)
  AppConfig.setEnvironment(Environment.dev);

  runApp(
    const ProviderScope(
      child: TulipApp(),
    ),
  );
}
