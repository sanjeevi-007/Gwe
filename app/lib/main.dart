import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'features/home/main_navigation_shell.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GwenApp(),
    ),
  );
}

class GwenApp extends StatelessWidget {
  const GwenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainNavigationShell(),
    );
  }
}
