import 'package:flutter/foundation.dart';
import 'enums.dart';

@immutable
class AiResult {
  final int? id;
  final String? deviceId;
  final DateTime tsDevice;
  final DateTime tsReceived;
  final AiLabel label;
  final int? score; // null if invalid or 255
  final int modelVersion;
  final AiSource source;
  final bool valid;

  const AiResult({
    this.id,
    this.deviceId,
    required this.tsDevice,
    required this.tsReceived,
    required this.label,
    this.score,
    required this.modelVersion,
    required this.source,
    required this.valid,
  });

  /// True if the result is computed via fallback rule-based heuristics.
  bool get isRuleBased => source == AiSource.ruleBased;

  /// True if the result was produced by an on-device trained neural network.
  bool get isTrained => source == AiSource.trainedModel;

  /// Honest display string honoring the hard rule: never claim AI for rule-based results.
  String get displayLabelString =>
      source == AiSource.ruleBased ? 'Motion estimate (rule-based)' : label.name;

  /// Checks if reading was received within [maxAgeSeconds].
  bool isFresh(int maxAgeSeconds) {
    return DateTime.now().difference(tsReceived).inSeconds <= maxAgeSeconds;
  }

  AiResult copyWith({
    int? id,
    String? deviceId,
    DateTime? tsDevice,
    DateTime? tsReceived,
    AiLabel? label,
    int? score,
    int? modelVersion,
    AiSource? source,
    bool? valid,
  }) {
    return AiResult(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsDevice: tsDevice ?? this.tsDevice,
      tsReceived: tsReceived ?? this.tsReceived,
      label: label ?? this.label,
      score: score ?? this.score,
      modelVersion: modelVersion ?? this.modelVersion,
      source: source ?? this.source,
      valid: valid ?? this.valid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiResult &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deviceId == other.deviceId &&
          tsDevice == other.tsDevice &&
          tsReceived == other.tsReceived &&
          label == other.label &&
          score == other.score &&
          modelVersion == other.modelVersion &&
          source == other.source &&
          valid == other.valid;

  @override
  int get hashCode => Object.hash(
        id,
        deviceId,
        tsDevice,
        tsReceived,
        label,
        score,
        modelVersion,
        source,
        valid,
      );

  @override
  String toString() =>
      'AiResult(id: $id, deviceId: $deviceId, label: $label, score: $score, modelVersion: $modelVersion, source: $source, valid: $valid, tsDevice: $tsDevice, tsReceived: $tsReceived)';
}
