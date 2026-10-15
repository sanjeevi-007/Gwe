import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gwen_app/features/pulse/pulse_screen.dart';
import 'package:gwen_app/models/models.dart';
import 'package:gwen_app/state/state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PulseScreen renders summary, range selector, chart, and disclaimer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();
    final testHistory = [
      PulseReading(
        deviceId: 'TEST',
        tsDevice: now.subtract(const Duration(seconds: 40)),
        tsReceived: now.subtract(const Duration(seconds: 40)),
        bpm: 72,
        quality: 90,
        state: PulseState.valid,
        valid: true,
      ),
      PulseReading(
        deviceId: 'TEST',
        tsDevice: now.subtract(const Duration(seconds: 38)),
        tsReceived: now.subtract(const Duration(seconds: 38)),
        bpm: 74,
        quality: 92,
        state: PulseState.valid,
        valid: true,
      ),
      // Reading after > 10s gap (gap is 18 seconds)
      PulseReading(
        deviceId: 'TEST',
        tsDevice: now.subtract(const Duration(seconds: 20)),
        tsReceived: now.subtract(const Duration(seconds: 20)),
        bpm: 80,
        quality: 95,
        state: PulseState.valid,
        valid: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pulseHistoryProvider.overrideWith((ref) => testHistory),
          latestPulseProvider.overrideWith(
            (ref) => Stream.value(testHistory.last),
          ),
        ],
        child: const MaterialApp(
          home: PulseScreen(),
        ),
      ),
    );

    // Initial pump and settle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Title & Summary
    expect(find.text('Pulse Insights'), findsOneWidget);
    expect(find.text('Current Heart Rate'), findsOneWidget);
    expect(find.text('80 BPM'), findsNWidgets(2));

    // Verify Time Range Selector
    expect(find.text('15 Min'), findsOneWidget);
    expect(find.text('1 Hour'), findsOneWidget);
    expect(find.text('24 Hours'), findsOneWidget);

    // Verify LineChart is rendered
    expect(find.byType(LineChart), findsOneWidget);

    // Inspect the LineChartData to confirm gap segmentation:
    final lineChartFinder = find.byType(LineChart);
    final lineChart = tester.widget<LineChart>(lineChartFinder);
    // There are 2 segments (due to the 18s gap)
    expect(lineChart.data.lineBarsData.length, 2);
    // Segment 1 has 2 points (72, 74)
    expect(lineChart.data.lineBarsData[0].spots.length, 2);
    // Segment 2 has 1 point (80)
    expect(lineChart.data.lineBarsData[1].spots.length, 1);
    // Neither segment has a 0 BPM point
    for (final bar in lineChart.data.lineBarsData) {
      for (final spot in bar.spots) {
        expect(spot.y, isNot(0));
      }
    }

    // Verify Non-Medical Disclaimer Text
    expect(
      find.textContaining('Not a medical device. Heart rate measurements are for general fitness monitoring'),
      findsOneWidget,
    );

    // Switch range to 1 Hour
    await tester.tap(find.text('1 Hour'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pumpWidget(const SizedBox());
  });
}
