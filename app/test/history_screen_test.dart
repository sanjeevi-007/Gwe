import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gwen_app/features/history/history_screen.dart';
import 'package:gwen_app/features/pulse/pulse_screen.dart';
import 'package:gwen_app/models/models.dart';
import 'package:gwen_app/state/state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HistoryScreen renders averages, missing-data breakdown, and navigation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();

    final testPulseHistory = [
      PulseReading(
        deviceId: 'TEST',
        tsDevice: now.subtract(const Duration(minutes: 10)),
        tsReceived: now.subtract(const Duration(minutes: 10)),
        bpm: 68,
        quality: 90,
        state: PulseState.valid,
        valid: true,
      ),
      PulseReading(
        deviceId: 'TEST',
        tsDevice: now.subtract(const Duration(minutes: 5)),
        tsReceived: now.subtract(const Duration(minutes: 5)),
        bpm: 78,
        quality: 95,
        state: PulseState.valid,
        valid: true,
      ),
    ];

    final testMotionHistory = [
      MotionReading(
        deviceId: 'TEST',
        tsDevice: now.subtract(const Duration(minutes: 10)),
        tsReceived: now.subtract(const Duration(minutes: 10)),
        ax: 10,
        ay: -980,
        az: 10,
        gx: 0,
        gy: 0,
        gz: 0,
        intensity: 45,
        valid: true,
      ),
      MotionReading(
        deviceId: 'TEST',
        tsDevice: now.subtract(const Duration(minutes: 5)),
        tsReceived: now.subtract(const Duration(minutes: 5)),
        ax: 20,
        ay: -950,
        az: 15,
        gx: 10,
        gy: 10,
        gz: 10,
        intensity: 85,
        valid: true,
      ),
    ];

    final testGpsHistory = [
      GpsReading(
        deviceId: 'TEST',
        tsDevice: now.subtract(const Duration(minutes: 10)),
        tsReceived: now.subtract(const Duration(minutes: 10)),
        fixState: GpsFixState.fix,
        lat: 37.7749,
        lon: -122.4194,
        satellites: 7,
        hdop: 1.5,
        valid: true,
        stale: false,
      ),
    ];

    final testMissingPeriods = [
      MissingDataPeriod(
        start: now.subtract(const Duration(minutes: 8)),
        end: now.subtract(const Duration(minutes: 6)),
        duration: const Duration(minutes: 2),
        metric: 'Pulse / Heart Rate',
        reason: 'Poor optical signal / sensor decoupled',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pulseHistoryProvider.overrideWith((ref) => testPulseHistory),
          motionHistoryProvider.overrideWith((ref) => testMotionHistory),
          gpsHistoryProvider.overrideWith((ref) => testGpsHistory),
          missingDataPeriodsProvider.overrideWith((ref) => testMissingPeriods),
        ],
        child: const MaterialApp(
          home: HistoryScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Title
    expect(find.text('History & Telemetry Log'), findsOneWidget);

    // Verify Range Selector
    expect(find.text('1 Hour'), findsOneWidget);
    expect(find.text('24 Hours'), findsOneWidget);
    expect(find.text('7 Days'), findsOneWidget);

    // Verify Heart Rate Averages
    expect(find.text('Heart Rate Historical Averages'), findsOneWidget);
    expect(find.text('73 BPM'), findsOneWidget); // (68 + 78) / 2 = 73
    expect(find.text('68 BPM'), findsOneWidget);
    expect(find.text('78 BPM'), findsOneWidget);

    // Verify Motion Summary
    expect(find.text('Motion & Movement Summary'), findsOneWidget);
    expect(find.text('65 / 255'), findsOneWidget); // (45 + 85) / 2 = 65
    expect(find.text('85 / 255'), findsOneWidget);

    // Verify GPS Averages
    expect(find.text('GPS Availability & Lock Stats'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);

    // Verify Missing-Data Periods Card
    expect(find.text('Missing-Data & Dropouts Breakdown'), findsOneWidget);
    expect(find.textContaining('Total Gap Periods: 1'), findsOneWidget);
    expect(find.textContaining('Missing Time: 2m 0s'), findsOneWidget);
    expect(find.text('Poor optical signal / sensor decoupled'), findsOneWidget);

    // Verify Navigation Chips
    expect(find.text('Pulse Insights'), findsOneWidget);
    expect(find.text('Motion & IMU'), findsOneWidget);
    expect(find.text('GPS Location'), findsOneWidget);
    expect(find.text('AI Insights'), findsOneWidget);

    // Tap Navigation Chip to PulseScreen
    await tester.tap(find.text('Pulse Insights'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PulseScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
