import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gwen_app/features/location/location_screen.dart';
import 'package:gwen_app/models/models.dart';
import 'package:gwen_app/state/state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LocationScreen displays all 6 GPS states properly', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();

    // 1. Test Fixed State (Active Fix)
    final fixedGps = GpsReading(
      deviceId: 'TEST',
      tsDevice: now,
      tsReceived: now,
      fixState: GpsFixState.fix,
      lat: 37.774929,
      lon: -122.419416,
      satellites: 8,
      hdop: 1.2,
      valid: true,
      stale: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          latestGpsProvider.overrideWith((ref) => Stream.value(fixedGps)),
          gpsHistoryProvider.overrideWith((ref) => [fixedGps]),
        ],
        child: const MaterialApp(
          home: LocationScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Location & GPS'), findsOneWidget);
    expect(find.text('State 2/6: 3D GPS Fix Active'), findsOneWidget);
    expect(find.text('37.774929°'), findsOneWidget);
    expect(find.text('-122.419416°'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('1.2'), findsOneWidget);
    expect(find.text('Excellent (1-2)'), findsOneWidget);
    expect(find.text('6-State GPS Protocol Specification'), findsOneWidget);
    expect(find.textContaining('Offline Privacy Guarantee'), findsOneWidget);

    // 2. Test Weak Fix State
    final weakGps = fixedGps.copyWith(
      tsReceived: DateTime.now(),
      fixState: GpsFixState.weak,
      hdop: 6.5,
      satellites: 4,
    );
    await tester.pumpWidget(
      ProviderScope(
        key: const Key('scope_weak'),
        overrides: [
          latestGpsProvider.overrideWith((ref) => Stream.value(weakGps)),
          gpsHistoryProvider.overrideWith((ref) => [weakGps]),
        ],
        child: const MaterialApp(
          home: LocationScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('State 3/6: Weak GPS Fix'), findsOneWidget);

    // 3. Test Searching State
    final searchingGps = fixedGps.copyWith(
      tsReceived: DateTime.now(),
      fixState: GpsFixState.searching,
      lat: null,
      lon: null,
      satellites: 2,
      valid: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        key: const Key('scope_searching'),
        overrides: [
          latestGpsProvider.overrideWith((ref) => Stream.value(searchingGps)),
          gpsHistoryProvider.overrideWith((ref) => []),
        ],
        child: const MaterialApp(
          home: LocationScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('State 1/6: Searching for Satellites'), findsOneWidget);

    // 4. Test No Fix State
    final noFixGps = fixedGps.copyWith(
      tsReceived: DateTime.now(),
      fixState: GpsFixState.noFix,
      lat: null,
      lon: null,
      satellites: 1,
      valid: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        key: const Key('scope_nofix'),
        overrides: [
          latestGpsProvider.overrideWith((ref) => Stream.value(noFixGps)),
          gpsHistoryProvider.overrideWith((ref) => []),
        ],
        child: const MaterialApp(
          home: LocationScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('State 4/6: No Satellite Lock'), findsOneWidget);

    // 5. Test Disconnected State
    final disconnectedGps = fixedGps.copyWith(
      tsReceived: DateTime.now(),
      fixState: GpsFixState.disconnected,
      valid: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        key: const Key('scope_disconnected'),
        overrides: [
          latestGpsProvider.overrideWith((ref) => Stream.value(disconnectedGps)),
          gpsHistoryProvider.overrideWith((ref) => []),
        ],
        child: const MaterialApp(
          home: LocationScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('State 5/6: GPS Receiver Disconnected'), findsOneWidget);

    // 6. Test Stale/Unavailable State (timestamp > 30s)
    final staleGps = fixedGps.copyWith(
      tsReceived: DateTime.now().subtract(const Duration(seconds: 45)),
      stale: true,
    );
    await tester.pumpWidget(
      ProviderScope(
        key: const Key('scope_stale'),
        overrides: [
          latestGpsProvider.overrideWith((ref) => Stream.value(staleGps)),
          gpsHistoryProvider.overrideWith((ref) => []),
        ],
        child: const MaterialApp(
          home: LocationScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('State 6/6: Stale / Unavailable'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
