import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gwen_app/features/ai_insights/ai_insights_screen.dart';
import 'package:gwen_app/models/models.dart';
import 'package:gwen_app/state/state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AiInsightsScreen displays active classification, pipeline, and limitations', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();

    // 1. Rule-based motion estimate test
    final ruleAi = AiResult(
      deviceId: 'TEST',
      tsDevice: now,
      tsReceived: now,
      label: AiLabel.walkingLike,
      score: 85,
      modelVersion: 1,
      source: AiSource.ruleBased,
      valid: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        key: const Key('scope_rule'),
        overrides: [
          latestAiResultProvider.overrideWith((ref) => Stream.value(ruleAi)),
          aiHistoryProvider.overrideWith((ref) => [ruleAi]),
        ],
        child: const MaterialApp(
          home: AiInsightsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Title & Rule-based Badge
    expect(find.text('AI Motion Insights'), findsOneWidget);
    expect(find.text('Walking-like Locomotion'), findsOneWidget);
    // Contract requirement: labeled "Motion estimate (rule-based)"
    expect(find.text('Motion estimate (rule-based)'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);

    // Verify Architecture Pipeline
    expect(find.text('On-Device Edge Architecture'), findsOneWidget);
    expect(find.text('1. MPU6050'), findsOneWidget);
    expect(find.text('2. ESP32'), findsOneWidget);
    expect(find.text('3. BLE Telemetry'), findsOneWidget);

    // Verify Mandatory Limitations Section
    expect(find.text('Mandatory Limitations & Honest Disclosure'), findsOneWidget);
    expect(find.text('• Not a Medical Device'), findsOneWidget);
    expect(find.text('• No Emergency or Fall Detection'), findsOneWidget);
    expect(find.text('• Microcontroller Sensor Limitations'), findsOneWidget);
    expect(find.text('• Honest Fallback Protocol'), findsOneWidget);

    // 2. Trained Model and Uncertain state test
    final trainedUncertainAi = AiResult(
      deviceId: 'TEST',
      tsDevice: now,
      tsReceived: now,
      label: AiLabel.uncertain,
      score: 42,
      modelVersion: 2,
      source: AiSource.trainedModel,
      valid: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        key: const Key('scope_trained'),
        overrides: [
          latestAiResultProvider.overrideWith((ref) => Stream.value(trainedUncertainAi)),
          aiHistoryProvider.overrideWith((ref) => [trainedUncertainAi]),
        ],
        child: const MaterialApp(
          home: AiInsightsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Uncertain Movement'), findsOneWidget);
    expect(find.text('Trained Model (TFLite Micro v2)'), findsOneWidget);
    expect(find.text('42%'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
