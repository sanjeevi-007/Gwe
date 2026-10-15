import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gwen_app/features/motion/motion_screen.dart';
import 'package:gwen_app/models/models.dart';
import 'package:gwen_app/state/state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MotionScreen renders friendly view, raw IMU toggle, chart, and disclaimer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();
    final testMotion = MotionReading(
      deviceId: 'TEST',
      tsDevice: now,
      tsReceived: now,
      ax: 120,
      ay: -980,
      az: 25,
      gx: 50, // 5.0 deg/s
      gy: -120, // -12.0 deg/s
      gz: 15, // 1.5 deg/s
      intensity: 75,
      valid: true,
    );

    final testHistory = [
      testMotion,
      MotionReading(
        deviceId: 'TEST',
        tsDevice: now.subtract(const Duration(seconds: 2)),
        tsReceived: now.subtract(const Duration(seconds: 2)),
        ax: 100,
        ay: -950,
        az: 30,
        gx: 40,
        gy: -100,
        gz: 10,
        intensity: 60,
        valid: true,
      ),
      // Gap > 10s
      MotionReading(
        deviceId: 'TEST',
        tsDevice: now.subtract(const Duration(seconds: 25)),
        tsReceived: now.subtract(const Duration(seconds: 25)),
        ax: 200,
        ay: -900,
        az: 50,
        gx: 80,
        gy: -150,
        gz: 30,
        intensity: 120,
        valid: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          latestMotionProvider.overrideWith((ref) => Stream.value(testMotion)),
          motionHistoryProvider.overrideWith((ref) => testHistory),
        ],
        child: const MaterialApp(
          home: MotionScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Title & Friendly Activity View
    expect(find.text('Movement & IMU'), findsOneWidget);
    expect(find.text('Activity View'), findsOneWidget);
    expect(find.text('Raw IMU Data'), findsOneWidget);
    expect(find.text('Walking-like Motion'), findsOneWidget);
    expect(find.text('75 / 255'), findsOneWidget);

    // Verify Motion Estimate (rule-based) label
    expect(find.text('Motion Estimate (Rule-based)'), findsOneWidget);

    // Verify Chart
    expect(find.byType(LineChart), findsOneWidget);

    // Verify Gap segmentation (2 segments due to 23s gap)
    final lineChart = tester.widget<LineChart>(find.byType(LineChart));
    expect(lineChart.data.lineBarsData.length, 2);

    // Verify Disclaimer
    expect(
      find.textContaining('Motion and intensity measurements are estimated from the ESP32 Puck IMU'),
      findsOneWidget,
    );

    // Tap "Raw IMU Data" toggle
    await tester.tap(find.text('Raw IMU Data'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Raw IMU channels are displayed
    expect(find.text('MPU6050 Raw 6-DOF Sensor Channels'), findsOneWidget);
    expect(find.text('ACCELEROMETER (mg)'), findsOneWidget);
    expect(find.text('GYROSCOPE (deg/s)'), findsOneWidget);
    expect(find.text('+120'), findsOneWidget);
    expect(find.text('-980'), findsOneWidget);
    expect(find.text('+25'), findsOneWidget);
    expect(find.text('5.0'), findsOneWidget);
    expect(find.text('-12.0'), findsOneWidget);
    expect(find.text('1.5'), findsOneWidget);
    expect(find.text('Total Accel Vector |A|'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
