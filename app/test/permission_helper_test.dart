import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gwen_app/core/permission_helper.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('PermissionHelper SDK and Parsing Tests', () {
    test('parseAndroidSdkVersion parses various OS version strings', () {
      expect(PermissionHelper.parseAndroidSdkVersion('Android 14 (API 34)'), 34);
      expect(PermissionHelper.parseAndroidSdkVersion('Android 13 (API: 33)'), 33);
      expect(PermissionHelper.parseAndroidSdkVersion('Android 12 (API 31)'), 31);
      expect(PermissionHelper.parseAndroidSdkVersion('Android 11 (API 30)'), 30);
      expect(PermissionHelper.parseAndroidSdkVersion('API 29'), 29);
      expect(PermissionHelper.parseAndroidSdkVersion('Android 10'), 29);
      expect(PermissionHelper.parseAndroidSdkVersion('Linux 5.15'), isNull);
    });

    test('isAndroid12OrNewer correctly checks API level >= 31', () {
      final helper33 = PermissionHelper(explicitAndroidSdkVersion: 33);
      expect(helper33.isAndroid12OrNewer, isTrue);

      final helper31 = PermissionHelper(explicitAndroidSdkVersion: 31);
      expect(helper31.isAndroid12OrNewer, isTrue);

      final helper30 = PermissionHelper(explicitAndroidSdkVersion: 30);
      expect(helper30.isAndroid12OrNewer, isFalse);

      final helper29 = PermissionHelper(explicitAndroidSdkVersion: 29);
      expect(helper29.isAndroid12OrNewer, isFalse);
    });
  });

  group('PermissionHelper Android 12+ (SDK >= 31) Tests', () {
    test('checkBlePermissions returns true when scan and connect are granted', () async {
      final helper = PermissionHelper(
        explicitAndroidSdkVersion: 33,
        permissionStatusChecker: (perm) async {
          if (perm == Permission.bluetoothScan || perm == Permission.bluetoothConnect) {
            return PermissionStatus.granted;
          }
          return PermissionStatus.denied;
        },
      );

      final result = await helper.checkBlePermissions();
      expect(result, isTrue);
    });

    test('checkBlePermissions returns false when bluetoothScan is denied', () async {
      final helper = PermissionHelper(
        explicitAndroidSdkVersion: 33,
        permissionStatusChecker: (perm) async {
          if (perm == Permission.bluetoothConnect) {
            return PermissionStatus.granted;
          }
          return PermissionStatus.denied;
        },
      );

      final result = await helper.checkBlePermissions();
      expect(result, isFalse);
    });

    test('requestBlePermissions requests bluetoothScan and bluetoothConnect', () async {
      final requested = <Permission>[];
      final helper = PermissionHelper(
        explicitAndroidSdkVersion: 33,
        permissionRequester: (permissions) async {
          requested.addAll(permissions);
          return {
            Permission.bluetoothScan: PermissionStatus.granted,
            Permission.bluetoothConnect: PermissionStatus.granted,
          };
        },
      );

      final result = await helper.requestBlePermissions();
      expect(result, isTrue);
      expect(requested, contains(Permission.bluetoothScan));
      expect(requested, contains(Permission.bluetoothConnect));
    });
  });

  group('PermissionHelper Android 11- (SDK < 31) Tests', () {
    test('checkBlePermissions returns true when locationWhenInUse is granted', () async {
      final helper = PermissionHelper(
        explicitAndroidSdkVersion: 30,
        permissionStatusChecker: (perm) async {
          if (perm == Permission.locationWhenInUse) {
            return PermissionStatus.granted;
          }
          return PermissionStatus.denied;
        },
      );

      final result = await helper.checkBlePermissions();
      expect(result, isTrue);
    });

    test('checkBlePermissions returns false when locationWhenInUse is denied', () async {
      final helper = PermissionHelper(
        explicitAndroidSdkVersion: 30,
        permissionStatusChecker: (perm) async {
          return PermissionStatus.denied;
        },
      );

      final result = await helper.checkBlePermissions();
      expect(result, isFalse);
    });

    test('requestBlePermissions invokes onShowLocationRationale and aborts if declined', () async {
      var rationaleShown = false;
      var requested = false;

      final helper = PermissionHelper(
        explicitAndroidSdkVersion: 30,
        permissionRequester: (permissions) async {
          requested = true;
          return {Permission.locationWhenInUse: PermissionStatus.granted};
        },
      );

      final result = await helper.requestBlePermissions(
        onShowLocationRationale: () async {
          rationaleShown = true;
          return false; // User cancels
        },
      );

      expect(rationaleShown, isTrue);
      expect(requested, isFalse);
      expect(result, isFalse);
    });

    test('requestBlePermissions proceeds to request location when rationale is accepted', () async {
      final requestedList = <Permission>[];
      final helper = PermissionHelper(
        explicitAndroidSdkVersion: 30,
        permissionRequester: (permissions) async {
          requestedList.addAll(permissions);
          return {
            Permission.locationWhenInUse: PermissionStatus.granted,
            Permission.bluetooth: PermissionStatus.granted,
          };
        },
      );

      final result = await helper.requestBlePermissions(
        onShowLocationRationale: () async => true,
      );

      expect(result, isTrue);
      expect(requestedList, contains(Permission.locationWhenInUse));
    });

    testWidgets('showLegacyLocationRationale renders alert dialog and handles actions',
        (tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await PermissionHelper.showLegacyLocationRationale(context);
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Location Permission Notice'), findsOneWidget);
      expect(
        find.textContaining('Android 11 and older requires Location permission'),
        findsOneWidget,
      );

      // Tap Understood & Continue
      await tester.tap(find.text('Understood & Continue'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
    });
  });
}
