import 'dart:async';
import 'dart:typed_data';

/// Predefined simulation scenarios for MockPuck.
enum MockScenario {
  /// Valid readings across all sensors (Pulse 72 BPM, Motion moderate, GPS fixed, AI walking-like, Battery 88%).
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
/// the exact protocol specification in docs/ble-protocol.md.
class MockPuck {
  MockScenario _scenario = MockScenario.normal;
  Timer? _timer;
  int _seq = 0;
  DateTime? _startTime;

  final StreamController<Uint8List> _packetStreamController =
      StreamController<Uint8List>.broadcast();

  /// The active simulation scenario.
  MockScenario get scenario => _scenario;

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

  /// Builds Type 0x01 Pulse packet (14 bytes).
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
        // default normal pulse reading
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

  /// Builds Type 0x02 Motion packet (23 bytes).
  Uint8List _buildMotionPacket({required int tMs}) {
    const flags = 0x01; // valid
    const ax = 50;
    const ay = -120;
    const az = 980;
    const gx = 2;
    const gy = -4;
    const gz = 1;
    const intensity = 35; // moderate movement
    const estClass = 1; // walking

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

  /// Builds Type 0x03 GPS packet (27 bytes with age_s).
  Uint8List _buildGpsPacket({required int tMs}) {
    int flags = 0x01;
    int fix = 1; // fix
    int sats = 8;
    int lat = 130826802; // 13.0826802 deg
    int lon = 802707184; // 80.2707184 deg
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
        lat = 130826802;
        lon = 802707184;
        hdop = 15;
        ageS = 45; // stale > 30s
        break;

      case MockScenario.normal:
      case MockScenario.poorSignal:
      case MockScenario.noFinger:
      case MockScenario.aiUncertain:
      case MockScenario.sensorError:
      case MockScenario.disconnected:
        // default normal GPS reading
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

  /// Builds Type 0x04 AI Result packet (14 bytes).
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
        // default normal AI result
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

  /// Builds Type 0x05 Device Status packet (18 bytes).
  Uint8List _buildStatusPacket({required int tMs, required int uptimeS}) {
    const flags = 0x01;
    const fwMajor = 1;
    const fwMinor = 0;
    const fwPatch = 0;
    int sensors = 0x1F; // All 5 sensors ok (MAX30102, MPU6050, GPS, TFT, Model)
    const battery = 88;

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
