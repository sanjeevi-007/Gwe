import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_providers.dart';

/// Key for tracking if onboarding has been completed in app settings.
const String kOnboardingCompletedKey = 'onboarding_completed';

/// Future provider checking if onboarding has already been completed in app settings.
final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final value = await settingsRepo.getSetting(kOnboardingCompletedKey);
  return value == 'true';
});

/// Controller to complete onboarding and persist flag in database.
final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  return OnboardingController(ref);
});

class OnboardingController {
  final Ref _ref;

  OnboardingController(this._ref);

  Future<void> completeOnboarding() async {
    final settingsRepo = _ref.read(settingsRepositoryProvider);
    await settingsRepo.setSetting(kOnboardingCompletedKey, 'true');
    _ref.invalidate(hasCompletedOnboardingProvider);
  }

  Future<void> resetOnboarding() async {
    final settingsRepo = _ref.read(settingsRepositoryProvider);
    await settingsRepo.setSetting(kOnboardingCompletedKey, 'false');
    _ref.invalidate(hasCompletedOnboardingProvider);
  }
}
