enum SequenceStatus {
  valid,
  duplicate,
  dropped,
}

class PacketSequenceResult {
  final SequenceStatus status;
  final int expectedSeq;
  final int receivedSeq;
  final int droppedCount;

  const PacketSequenceResult({
    required this.status,
    required this.expectedSeq,
    required this.receivedSeq,
    this.droppedCount = 0,
  });

  @override
  String toString() =>
      'PacketSequenceResult(status: $status, expected: $expectedSeq, received: $receivedSeq, dropped: $droppedCount)';
}

/// Tracks 16-bit packet sequence numbers to detect duplicates and dropped packets.
class SequenceTracker {
  int? _lastSeq;

  int? get lastSeq => _lastSeq;

  PacketSequenceResult processSequence(int currentSeq) {
    if (_lastSeq == null) {
      _lastSeq = currentSeq;
      return PacketSequenceResult(
        status: SequenceStatus.valid,
        expectedSeq: currentSeq,
        receivedSeq: currentSeq,
        droppedCount: 0,
      );
    }

    final last = _lastSeq!;
    final expected = (last + 1) & 0xFFFF;

    if (currentSeq == last) {
      return PacketSequenceResult(
        status: SequenceStatus.duplicate,
        expectedSeq: expected,
        receivedSeq: currentSeq,
        droppedCount: 0,
      );
    }

    if (currentSeq == expected) {
      _lastSeq = currentSeq;
      return PacketSequenceResult(
        status: SequenceStatus.valid,
        expectedSeq: expected,
        receivedSeq: currentSeq,
        droppedCount: 0,
      );
    }

    // Sequence gap detected with 16-bit wrap-around handling
    final dropped = (currentSeq - expected) & 0xFFFF;
    _lastSeq = currentSeq;

    return PacketSequenceResult(
      status: SequenceStatus.dropped,
      expectedSeq: expected,
      receivedSeq: currentSeq,
      droppedCount: dropped,
    );
  }

  void reset() {
    _lastSeq = null;
  }
}
