/// State of the pulse sensor (MAX30102).
enum PulseState {
  measuring(0),
  valid(1),
  poorSignal(2),
  noFinger(3),
  sensorError(4);

  final int rawValue;
  const PulseState(this.rawValue);

  static PulseState fromRawValue(int value) {
    for (final state in PulseState.values) {
      if (state.rawValue == value) return state;
    }
    return PulseState.sensorError;
  }
}

/// State of the GPS receiver (NEO-6M).
enum GpsFixState {
  searching(0),
  fix(1),
  weak(2),
  noFix(3),
  disconnected(4);

  final int rawValue;
  const GpsFixState(this.rawValue);

  static GpsFixState fromRawValue(int value) {
    for (final state in GpsFixState.values) {
      if (state.rawValue == value) return state;
    }
    return GpsFixState.disconnected;
  }
}

/// Classification label from the AI motion model.
enum AiLabel {
  stationary(0),
  walkingLike(1),
  vigorous(2),
  uncertain(3),
  unavailable(255);

  final int rawValue;
  const AiLabel(this.rawValue);

  static AiLabel fromRawValue(int value) {
    for (final label in AiLabel.values) {
      if (label.rawValue == value) return label;
    }
    return AiLabel.unavailable;
  }
}

/// Origin source of the AI motion label.
enum AiSource {
  none(0),
  ruleBased(1),
  trainedModel(2);

  final int rawValue;
  const AiSource(this.rawValue);

  static AiSource fromRawValue(int value) {
    for (final source in AiSource.values) {
      if (source.rawValue == value) return source;
    }
    return AiSource.none;
  }
}
