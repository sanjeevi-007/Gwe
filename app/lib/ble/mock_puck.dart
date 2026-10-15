import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

/// Active physical motion simulation mode for MockPuck.
enum MockMotionMode {
  /// Stationary posture (seated or resting). Low intensity <= 15, low BPM (65-75).
  stationary,

  /// Typical walking cadence. Moderate intensity (20-50), moderate BPM (80-115).
  walking,

  /// High-exertion running or exercise. High intensity >= 60, elevated BPM (120-140).
  vigorous,
}

/// Predefined simulation scenarios for MockPuck.
enum MockScenario {
  /// Valid readings across all sensors (Pulse fluctuating, dynamic IMU, GPS walking path, AI, Battery).
  normal,

  /// Pulse state = poorSignal (2), quality = 15, valid = false.
  poorSignal,

  /// Pulse state = noFinger (3), BPM = 0xFFFF, valid = false.
  noFinger,

  /// GPS fix = searching (0), lat/lon = 0x7FFFFFFF (NULL), sats = 2, valid = false.
  gpsSearching,

  /// GPS fix = fix (1), age_s = 45 (stale > 30s), flags bit1 stale set.
  gpsStale,

  /// AI label = uncertain (3), score = 30, source = ruleBased (1).
  aiUncertain,

  /// Pulse state = sensorError (4), header flags bit2 set.
  sensorError,

  /// Stops emitting data packets, simulates link loss.
  disconnected,
}

/// Fake Puck device simulator that produces raw binary BLE packets matching
/// the exact protocol specification in docs/ble-protocol.md with realistic
/// physiological, 6-axis IMU, and walking route dynamics.
class MockPuck {
  MockScenario _scenario = MockScenario.normal;
  MockMotionMode _motionMode = MockMotionMode.walking;
  Timer? _timer;
  int _seq = 0;
  int _tickCount = 0;
  DateTime? _startTime;

  // Base coordinates: Marina Beach Promenade, Chennai
  static const int baseLat = 130826802; // 13.0826802 deg
  static const int baseLon = 802707184; // 80.2707184 deg

  final StreamController<Uint8List> _packetStreamController =
      StreamController<Uint8List>.broadcast();

  /// The active simulation scenario.
  MockScenario get scenario => _scenario;

  /// The active physical motion mode.
  MockMotionMode get motionMode => _motionMode;

  /// Number of periodic bursts generated.
  int get tickCount => _tickCount;

  /// Current packet sequence counter.
  int get seq => _seq;

  /// Whether the periodic packet emitter is currently running.
  bool get isRunning => _timer != null && _timer!.isActive;

  /// Broadcast stream of raw binary BLE packets (Uint8List).
  Stream<Uint8List> get packetStream => _packetStreamController.stream;

  /// Sets the active simulation scenario.
  void setScenario(MockScenario scenario) {
    _scenario = scenario;
  }

  /// Sets the physical motion mode (Stationary, Walking, Vigorous).
  void setMotionMode(MockMotionMode mode) {
    _motionMode = mode;
  }

  /// Resets simulation tick counters and sequence numbers.
  void resetSimulation() {
    _seq = 0;
    _tickCount = 0;
    _startTime = DateTime.now();
  }

  /// Begins the 1000ms periodic timer emitting 5-packet bursts.
  /// Also emits an initial burst immediately on start.
  void start() {
    stop();
    _startTime ??= DateTime.now();
    emitBurst();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      emitBurst();
    });
  }

  /// Stops the periodic timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Closes the stream controller and releases timer resources.
  void dispose() {
    stop();
    _packetStreamController.close();
  }

  /// Emits a 5-packet burst (Pulse, Motion, GPS, AI, Status) into [packetStream],
  /// unless the active scenario is [MockScenario.disconnected].
  void emitBurst() {
    if (_scenario == MockScenario.disconnected) {
      return;
    }

    final uptimeMs = _startTime != null
        ? DateTime.now().difference(_startTime!).inMilliseconds
        : 1000;
    final uptimeS = uptimeMs ~/ 1000;

    final pulsePacket = _buildPulsePacket(tMs: uptimeMs);
    final motionPacket = _buildMotionPacket(tMs: uptimeMs);
    final gpsPacket = _buildGpsPacket(tMs: uptimeMs);
    final aiPacket = _buildAiPacket(tMs: uptimeMs);
    final statusPacket = _buildStatusPacket(tMs: uptimeMs, uptimeS: uptimeS);

    if (!_packetStreamController.isClosed) {
      _packetStreamController.add(pulsePacket);
      _packetStreamController.add(motionPacket);
      _packetStreamController.add(gpsPacket);
      _packetStreamController.add(aiPacket);
      _packetStreamController.add(statusPacket);
    }

    _tickCount++;
  }

  int _nextSeq() {
    _seq = (_seq + 1) & 0xFFFF;
    return _seq;
  }

  Uint8List _buildHeader({
    required int type,
    required int tMs,
    required int flags,
  }) {
    final bytes = Uint8List(9);
    final bd = ByteData.sublistView(bytes);
    bd.setUint8(0, 0x01); // ver = 1
    bd.setUint8(1, type);
    bd.setUint16(2, _nextSeq(), Endian.little);
    bd.setUint32(4, tMs, Endian.little);
    bd.setUint8(8, flags);
    return bytes;
  }

  /// Builds Type 0x01 Pulse packet (14 bytes) with sine-wave fluctuating heart rate.
  Uint8List _buildPulsePacket({required int tMs}) {
    int flags = 0x01; // bit 0 valid
    int bpm = 72;
    const int spo2 = 0xFF; // SpO2 permanently disabled in v1
    int quality = 90;
    int state = 1; // PulseState.valid

    switch (_scenario) {
      case MockScenario.poorSignal:
        flags = 0x00; // valid = false
        quality = 15;
        state = 2; // PulseState.poorSignal
        bpm = 70;
        break;

      case MockScenario.noFinger:
        flags = 0x00; // valid = false
        bpm = 0xFFFF; // no finger / invalid
        quality = 0;
        state = 3; // PulseState.noFinger
        break;

      case MockScenario.sensorError:
        flags = 0x04; // bit 2 sensor_error, valid = false
        bpm = 0xFFFF;
        quality = 0;
        state = 4; // PulseState.sensorError
        break;

      case MockScenario.normal:
      case MockScenario.gpsSearching:
      case MockScenario.gpsStale:
      case MockScenario.aiUncertain:
      case MockScenario.disconnected:
        if (_tickCount == 0) {
          // Backward-compatible deterministic base reading on tick 0
          bpm = 72;
          quality = 90;
        } else {
          // Dynamic sine-wave fluctuation across 65-140 BPM based on motion mode
          final t = _tickCount;
          switch (_motionMode) {
            case MockMotionMode.stationary:
              // Calm resting heart rate: 68-75 BPM
              bpm = (71.0 + 4.0 * math.sin(t * 0.15)).round();
              quality = 95;
              break;
            case MockMotionMode.walking:
              // Moderate walking heart rate: 85-115 BPM
              bpm = (100.0 + 15.0 * math.sin(t * 0.12)).round();
              quality = 90;
              break;
            case MockMotionMode.vigorous:
              // Intense exercise heart rate: 125-140 BPM
              bpm = (132.0 + 8.0 * math.sin(t * 0.20)).round();
              quality = 82;
              break;
          }
        }
        break;
    }

    final bytes = Uint8List(14);
    bytes.setRange(0, 9, _buildHeader(type: 0x01, tMs: tMs, flags: flags));
    final bd = ByteData.sublistView(bytes);
    bd.setUint16(9, bpm, Endian.little);
    bd.setUint8(11, spo2);
    bd.setUint8(12, quality);
    bd.setUint8(13, state);
    return bytes;
  }

  /// Builds Type 0x02 Motion packet (23 bytes) with dynamic 6-axis acceleration vectors and gyros.
  Uint8List _buildMotionPacket({required int tMs}) {
    const flags = 0x01; // valid

    int ax = 50;
    int ay = -120;
    int az = 980;
    int gx = 2;
    int gy = -4;
    int gz = 1;
    int intensity = 35; // moderate movement
    int estClass = 1; // walking

    if (_tickCount == 0) {
      // Deterministic initial values matching test fixtures
      ax = 50;
      ay = -120;
      az = 980;
      gx = 2;
      gy = -4;
      gz = 1;
      intensity = 35;
      estClass = 1;
    } else {
      final t = _tickCount;
      final phase = (t * 0.4) % (2 * math.pi);

      switch (_motionMode) {
        case MockMotionMode.stationary:
          // Low noise around 1G gravity vector
          ax = (math.sin(phase) * 15).round();
          ay = (math.cos(phase) * 15).round();
          az = (980 + math.sin(phase * 2) * 10).round();
          gx = (math.sin(phase) * 1).round();
          gy = (math.cos(phase) * 1).round();
          gz = 0;
          intensity = 8; // <= 15
          estClass = 0; // stationary
          break;

        case MockMotionMode.walking:
          // Rhythmic stride acceleration waves (mg) and arm swing rotation (deg/s * 10)
          ax = (50 + math.sin(phase) * 280).round();
          ay = (-120 + math.cos(phase) * 380).round();
          az = (980 + math.sin(phase * 2) * 220).round();
          gx = (math.sin(phase) * 18).round();
          gy = (math.cos(phase) * -22).round();
          gz = (math.sin(phase * 0.5) * 12).round();
          intensity = 35; // moderate movement
          estClass = 1; // walking
          break;

        case MockMotionMode.vigorous:
          // High exertion acceleration spikes and sharp rotations
          ax = (math.sin(phase) * 1100).round();
          ay = (math.cos(phase) * 1350).round();
          az = (1200 + math.sin(phase * 2) * 800).round();
          gx = (math.sin(phase) * 95).round();
          gy = (math.cos(phase) * -110).round();
          gz = (math.sin(phase * 0.5) * 60).round();
          intensity = 78; // >= 60
          estClass = 2; // vigorous
          break;
      }
    }

    final bytes = Uint8List(23);
    bytes.setRange(0, 9, _buildHeader(type: 0x02, tMs: tMs, flags: flags));
    final bd = ByteData.sublistView(bytes);
    bd.setInt16(9, ax, Endian.little);
    bd.setInt16(11, ay, Endian.little);
    bd.setInt16(13, az, Endian.little);
    bd.setInt16(15, gx, Endian.little);
    bd.setInt16(17, gy, Endian.little);
    bd.setInt16(19, gz, Endian.little);
    bd.setUint8(21, intensity);
    bd.setUint8(22, estClass);
    return bytes;
  }

  /// Builds Type 0x03 GPS packet (27 bytes) with smooth walking route drift.
  Uint8List _buildGpsPacket({required int tMs}) {
    int flags = 0x01;
    int fix = 1; // fix
    int sats = 8;
    int lat = baseLat; // 13.0826802 deg
    int lon = baseLon; // 80.2707184 deg
    int hdop = 12; // 1.2
    final utc = (DateTime.now().millisecondsSinceEpoch ~/ 1000) & 0xFFFFFFFF;
    int ageS = 1;

    switch (_scenario) {
      case MockScenario.gpsSearching:
        flags = 0x00; // valid = false
        fix = 0; // searching
        sats = 2;
        lat = 0x7FFFFFFF; // NULL
        lon = 0x7FFFFFFF; // NULL
        hdop = 0xFFFF;
        ageS = 0;
        break;

      case MockScenario.gpsStale:
        flags = 0x03; // bit 0 valid, bit 1 stale set
        fix = 1;
        sats = 7;
        lat = baseLat;
        lon = baseLon;
        hdop = 15;
        ageS = 45; // stale > 30s
        break;

      case MockScenario.normal:
      case MockScenario.poorSignal:
      case MockScenario.noFinger:
      case MockScenario.aiUncertain:
      case MockScenario.sensorError:
      case MockScenario.disconnected:
        if (_tickCount == 0) {
          lat = baseLat;
          lon = baseLon;
        } else {
          // Drifts smoothly along an elliptical walking circuit (radius ~100m, ~1.2 m/s step)
          final progress = (_tickCount * 0.05) % (2 * math.pi);
          const int latRadius = 650; // ~72 meters North-South
          const int lonRadius = 850; // ~90 meters East-West

          lat = (baseLat + math.sin(progress) * latRadius).round();
          lon = (baseLon + math.cos(progress) * lonRadius).round();
          sats = 9;
          hdop = 10; // 1.0 HDOP excellent fix
        }
        break;
    }

    final bytes = Uint8List(27);
    bytes.setRange(0, 9, _buildHeader(type: 0x03, tMs: tMs, flags: flags));
    final bd = ByteData.sublistView(bytes);
    bd.setUint8(9, fix);
    bd.setUint8(10, sats);
    bd.setInt32(11, lat, Endian.little);
    bd.setInt32(15, lon, Endian.little);
    bd.setUint16(19, hdop, Endian.little);
    bd.setUint32(21, utc, Endian.little);
    bd.setUint16(25, ageS, Endian.little);
    return bytes;
  }

  /// Builds Type 0x04 AI Result packet (14 bytes) synchronized with motion mode.
  Uint8List _buildAiPacket({required int tMs}) {
    const flags = 0x01;
    int label = 1; // walkingLike
    int score = 88;
    const modelVer = 1;
    int source = 2; // trainedModel

    switch (_scenario) {
      case MockScenario.aiUncertain:
        label = 3; // uncertain
        score = 30;
        source = 1; // ruleBased
        break;

      case MockScenario.normal:
      case MockScenario.poorSignal:
      case MockScenario.noFinger:
      case MockScenario.gpsSearching:
      case MockScenario.gpsStale:
      case MockScenario.sensorError:
      case MockScenario.disconnected:
        if (_tickCount == 0) {
          label = 1; // walkingLike
          score = 88;
        } else {
          switch (_motionMode) {
            case MockMotionMode.stationary:
              label = 0; // stationary
              score = 96;
              break;
            case MockMotionMode.walking:
              label = 1; // walkingLike
              score = 88;
              break;
            case MockMotionMode.vigorous:
              label = 2; // vigorous
              score = 92;
              break;
          }
        }
        break;
    }

    final bytes = Uint8List(14);
    bytes.setRange(0, 9, _buildHeader(type: 0x04, tMs: tMs, flags: flags));
    final bd = ByteData.sublistView(bytes);
    bd.setUint8(9, label);
    bd.setUint8(10, score);
    bd.setUint16(11, modelVer, Endian.little);
    bd.setUint8(13, source);
    return bytes;
  }

  /// Builds Type 0x05 Device Status packet (18 bytes) with gradual battery drain.
  Uint8List _buildStatusPacket({required int tMs, required int uptimeS}) {
    const flags = 0x01;
    const fwMajor = 1;
    const fwMinor = 0;
    const fwPatch = 0;
    int sensors = 0x1F; // All 5 sensors ok (MAX30102, MPU6050, GPS, TFT, Model)

    // Battery drains 1% every 120 seconds, maintaining 88% on initial ticks
    final battery = (88 - (uptimeS ~/ 120)).clamp(5, 100);

    if (_scenario == MockScenario.sensorError) {
      sensors = 0x1E; // MAX30102 bit 0 cleared due to error
    }

    final bytes = Uint8List(18);
    bytes.setRange(0, 9, _buildHeader(type: 0x05, tMs: tMs, flags: flags));
    final bd = ByteData.sublistView(bytes);
    bd.setUint8(9, fwMajor);
    bd.setUint8(10, fwMinor);
    bd.setUint8(11, fwPatch);
    bd.setUint8(12, sensors);
    bd.setUint32(13, uptimeS, Endian.little);
    bd.setUint8(17, battery);
    return bytes;
  }
}
