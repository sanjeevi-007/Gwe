import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gwen_app/data/database.dart';
import 'package:gwen_app/data/repositories/settings_repository.dart';
import 'package:gwen_app/features/home/main_navigation_shell.dart';
import 'package:gwen_app/features/onboarding/onboarding_screen.dart';
import 'package:gwen_app/main.dart';
import 'package:gwen_app/state/state.dart';

class FakeSettingsRepository implements SettingsRepository {
  final Map<String, String> _storage = {};

  @override
  AppDatabase get db => throw UnimplementedError();

  @override
  Future<void> setSetting(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getSetting(String key) async {
    return _storage[key];
  }

  @override
  Future<int> deleteAllSettings() async {
    final count = _storage.length;
    _storage.clear();
    return count;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Flow Tests', () {
    testWidgets('OnboardingScreen navigates through all 4 pages, requires disclaimer, and sets flag', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeSettings = FakeSettingsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(fakeSettings),
          ],
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // --- PAGE 1: Welcome ---
      expect(find.text('Welcome to GWEN'), findsOneWidget);
      expect(find.textContaining('100% Offline. Your data never leaves your device.'), findsOneWidget);
      expect(find.text('Continuous Vital Signs'), findsOneWidget);
      expect(find.byKey(const Key('back_button')), findsNothing); // Hidden on page 1

      // Advance to Page 2
      await tester.tap(find.byKey(const Key('next_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // --- PAGE 2: How It Works ---
      expect(find.text('How GWEN Works'), findsOneWidget);
      expect(find.text('MAX30102'), findsOneWidget);
      expect(find.text('MPU6050 + ESP32 AI'), findsOneWidget);
      expect(find.text('NEO-6M GPS'), findsOneWidget);
      expect(find.byKey(const Key('back_button')), findsOneWidget);

      // Advance to Page 3
      await tester.tap(find.byKey(const Key('next_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // --- PAGE 3: Privacy & Data Ownership ---
      expect(find.text('Privacy & Data Ownership'), findsOneWidget);
      expect(find.text('Local Drift SQLite Database'), findsOneWidget);
      expect(find.text('GPS Coordinates Stay Local'), findsOneWidget);

      // Advance to Page 4
      await tester.tap(find.byKey(const Key('next_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // --- PAGE 4: Medical Disclaimer ---
      expect(find.text('Important Health & Safety Notice'), findsOneWidget);
      expect(find.text('Mandatory Non-Medical Disclaimer & Terms'), findsOneWidget);
      expect(find.text('NOT a Medical Device'), findsOneWidget);
      expect(find.text('No Medical Diagnosis or Treatment'), findsOneWidget);
      expect(find.text('No Fall Detection or Emergency SOS'), findsOneWidget);
      expect(find.text('Seek Professional Medical Guidance'), findsOneWidget);

      // "Get Started" button exists but is disabled before accepting disclaimer
      final getStartedFinder = find.byKey(const Key('get_started_button'));
      expect(getStartedFinder, findsOneWidget);

      final buttonBeforeAccept = tester.widget<ElevatedButton>(getStartedFinder);
      expect(buttonBeforeAccept.onPressed, isNull); // Disabled

      // Toggle disclaimer checkbox
      await tester.tap(find.byKey(const Key('disclaimer_checkbox')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Button is now enabled
      final buttonAfterAccept = tester.widget<ElevatedButton>(getStartedFinder);
      expect(buttonAfterAccept.onPressed, isNotNull);

      // Tap "Get Started"
      await tester.tap(getStartedFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify flag is saved to settings database
      final savedFlag = await fakeSettings.getSetting('onboarding_completed');
      expect(savedFlag, 'true');

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Skip button navigates directly to Page 4 disclaimer', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeSettings = FakeSettingsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(fakeSettings),
          ],
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // On Page 1, tap Skip
      expect(find.byKey(const Key('skip_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('skip_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Directly on Page 4
      expect(find.text('Important Health & Safety Notice'), findsOneWidget);
      expect(find.byKey(const Key('get_started_button')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('GwenApp displays OnboardingScreen when not completed and MainNavigationShell when completed', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // 1. Not completed -> OnboardingScreen
      await tester.pumpWidget(
        ProviderScope(
          key: const Key('scope_first_launch'),
          overrides: [
            hasCompletedOnboardingProvider.overrideWith((ref) => false),
          ],
          child: const GwenApp(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(MainNavigationShell), findsNothing);

      // 2. Completed -> MainNavigationShell
      await tester.pumpWidget(
        ProviderScope(
          key: const Key('scope_completed_launch'),
          overrides: [
            hasCompletedOnboardingProvider.overrideWith((ref) => true),
          ],
          child: const GwenApp(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(MainNavigationShell), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
