import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'features/home/main_navigation_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'state/state.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GwenApp(),
    ),
  );
}

class GwenApp extends ConsumerWidget {
  const GwenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(hasCompletedOnboardingProvider);

    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: onboardingState.when(
        data: (completed) {
          if (completed) {
            return const MainNavigationShell();
          } else {
            return const OnboardingScreen();
          }
        },
        loading: () => const Scaffold(
          backgroundColor: AppTheme.darkBackground,
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.darkPrimary),
          ),
        ),
        error: (_, __) => const MainNavigationShell(),
      ),
    );
  }
}
