import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/routes.dart';
import 'config/theme.dart';

class TulipApp extends ConsumerWidget {
  const TulipApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Tulip',
      theme: tulipTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
