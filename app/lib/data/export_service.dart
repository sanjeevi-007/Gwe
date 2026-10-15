import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import 'repositories/repositories.dart';

/// Service responsible for exporting local SQLite telemetry records to CSV and JSON formats,
/// and sharing them offline via the Android system Share Sheet.
class ExportService {
  final PulseRepository pulseRepository;
  final MotionRepository motionRepository;
  final GpsRepository gpsRepository;
  final AiRepository aiRepository;
  final Future<void> Function(List<String> paths, {String? subject})? shareHandler;

  ExportService({
    required this.pulseRepository,
    required this.motionRepository,
    required this.gpsRepository,
    required this.aiRepository,
    this.shareHandler,
  });

  /// Formats pulse readings as RFC-4180 compliant CSV string.
  static String formatPulseCsv(List<PulseReading> readings) {
    final buffer = StringBuffer();
    buffer.writeln('id,deviceId,tsDevice,tsReceived,bpm,quality,state,valid');
    for (final r in readings) {
      buffer.writeln(
        '${r.id ?? ""},${r.deviceId ?? ""},${r.tsDevice.toIso8601String()},${r.tsReceived.toIso8601String()},${r.bpm ?? ""},${r.quality},${r.state.name},${r.valid}',
      );
    }
    return buffer.toString();
  }

  /// Formats motion readings as RFC-4180 compliant CSV string.
  static String formatMotionCsv(List<MotionReading> readings) {
    final buffer = StringBuffer();
    buffer.writeln(
      'id,deviceId,tsDevice,tsReceived,ax,ay,az,gx,gy,gz,intensity,valid',
    );
    for (final r in readings) {
      buffer.writeln(
        '${r.id ?? ""},${r.deviceId ?? ""},${r.tsDevice.toIso8601String()},${r.tsReceived.toIso8601String()},${r.ax},${r.ay},${r.az},${r.gx},${r.gy},${r.gz},${r.intensity},${r.valid}',
      );
    }
    return buffer.toString();
  }

  /// Formats GPS readings as RFC-4180 compliant CSV string.
  static String formatGpsCsv(List<GpsReading> readings) {
    final buffer = StringBuffer();
    buffer.writeln(
      'id,deviceId,tsDevice,tsReceived,fixState,lat,lon,satellites,hdop,valid,stale',
    );
    for (final r in readings) {
      buffer.writeln(
        '${r.id ?? ""},${r.deviceId ?? ""},${r.tsDevice.toIso8601String()},${r.tsReceived.toIso8601String()},${r.fixState.name},${r.lat ?? ""},${r.lon ?? ""},${r.satellites},${r.hdop ?? ""},${r.valid},${r.stale}',
      );
    }
    return buffer.toString();
  }

  /// Formats all telemetry history into a structured, indent-formatted JSON string.
  static String formatJsonExport({
    required List<PulseReading> pulse,
    required List<MotionReading> motion,
    required List<GpsReading> gps,
    required List<AiResult> ai,
    String appVersion = '0.5.0',
    DateTime? exportTime,
  }) {
    final exportDate = exportTime ?? DateTime.now();
    final data = {
      'gwen_export_version': appVersion,
      'exported_at': exportDate.toIso8601String(),
      'summary': {
        'total_pulse_records': pulse.length,
        'total_motion_records': motion.length,
        'total_gps_records': gps.length,
        'total_ai_records': ai.length,
      },
      'pulse_readings': pulse
          .map((r) => {
                'id': r.id,
                'deviceId': r.deviceId,
                'tsDevice': r.tsDevice.toIso8601String(),
                'tsReceived': r.tsReceived.toIso8601String(),
                'bpm': r.bpm,
                'quality': r.quality,
                'state': r.state.name,
                'valid': r.valid,
              })
          .toList(),
      'motion_readings': motion
          .map((r) => {
                'id': r.id,
                'deviceId': r.deviceId,
                'tsDevice': r.tsDevice.toIso8601String(),
                'tsReceived': r.tsReceived.toIso8601String(),
                'ax': r.ax,
                'ay': r.ay,
                'az': r.az,
                'gx': r.gx,
                'gy': r.gy,
                'gz': r.gz,
                'intensity': r.intensity,
                'valid': r.valid,
              })
          .toList(),
      'gps_readings': gps
          .map((r) => {
                'id': r.id,
                'deviceId': r.deviceId,
                'tsDevice': r.tsDevice.toIso8601String(),
                'tsReceived': r.tsReceived.toIso8601String(),
                'fixState': r.fixState.name,
                'lat': r.lat,
                'lon': r.lon,
                'satellites': r.satellites,
                'hdop': r.hdop,
                'valid': r.valid,
                'stale': r.stale,
              })
          .toList(),
      'ai_results': ai
          .map((r) => {
                'id': r.id,
                'deviceId': r.deviceId,
                'tsDevice': r.tsDevice.toIso8601String(),
                'tsReceived': r.tsReceived.toIso8601String(),
                'label': r.label.name,
                'score': r.score,
                'modelVersion': r.modelVersion,
                'source': r.source.name,
                'valid': r.valid,
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Queries all historical readings, writes CSV files to temporary directory,
  /// and invokes system share sheet.
  Future<List<String>> exportCsvAndShare({Directory? targetDirectory}) async {
    final dir = targetDirectory ?? await getTemporaryDirectory();
    final now = DateTime.now();
    final start = DateTime.fromMillisecondsSinceEpoch(0);

    final pulse = await pulseRepository.getPulseHistory(start, now);
    final motion = await motionRepository.getMotionHistory(start, now);
    final gps = await gpsRepository.getGpsHistory(start, now);

    final ts = now.millisecondsSinceEpoch;
    final pulseFile = File('${dir.path}/gwen_pulse_$ts.csv');
    final motionFile = File('${dir.path}/gwen_motion_$ts.csv');
    final gpsFile = File('${dir.path}/gwen_gps_$ts.csv');

    await pulseFile.writeAsString(formatPulseCsv(pulse));
    await motionFile.writeAsString(formatMotionCsv(motion));
    await gpsFile.writeAsString(formatGpsCsv(gps));

    final paths = [pulseFile.path, motionFile.path, gpsFile.path];
    await _share(paths, subject: 'GWEN Telemetry History (CSV)');
    return paths;
  }

  /// Queries all historical readings, writes a single JSON export file,
  /// and invokes system share sheet.
  Future<String> exportJsonAndShare({Directory? targetDirectory}) async {
    final dir = targetDirectory ?? await getTemporaryDirectory();
    final now = DateTime.now();
    final start = DateTime.fromMillisecondsSinceEpoch(0);

    final pulse = await pulseRepository.getPulseHistory(start, now);
    final motion = await motionRepository.getMotionHistory(start, now);
    final gps = await gpsRepository.getGpsHistory(start, now);
    final ai = await aiRepository.getAiHistory(start, now);

    final ts = now.millisecondsSinceEpoch;
    final jsonFile = File('${dir.path}/gwen_export_$ts.json');

    final jsonContent = formatJsonExport(
      pulse: pulse,
      motion: motion,
      gps: gps,
      ai: ai,
      exportTime: now,
    );

    await jsonFile.writeAsString(jsonContent);

    await _share([jsonFile.path], subject: 'GWEN Full Telemetry Export (JSON)');
    return jsonFile.path;
  }

  Future<void> _share(List<String> paths, {String? subject}) async {
    final handler = shareHandler;
    if (handler != null) {
      await handler(paths, subject: subject);
      return;
    }

    final xFiles = paths.map((p) => XFile(p)).toList();
    await Share.shareXFiles(xFiles, subject: subject);
  }
}
