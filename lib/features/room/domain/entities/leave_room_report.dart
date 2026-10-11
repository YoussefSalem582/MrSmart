import 'package:equatable/equatable.dart';

enum LeaveOutcome { confirmed, alreadyOff, failed, unconfirmed, skipped }

class LeaveRoomEntry extends Equatable {
  const LeaveRoomEntry(this.entityId, this.name, this.outcome);
  final String entityId;
  final String name;
  final LeaveOutcome outcome;

  @override
  List<Object?> get props => [entityId, name, outcome];
}

class LeaveRoomReport extends Equatable {
  const LeaveRoomReport(this.entries, {this.notConnected = false});

  final List<LeaveRoomEntry> entries;

  /// Nothing was sent because the app was offline.
  final bool notConnected;

  bool get allOff =>
      !notConnected &&
      entries.every(
        (e) =>
            e.outcome == LeaveOutcome.confirmed ||
            e.outcome == LeaveOutcome.alreadyOff,
      );

  @override
  List<Object?> get props => [entries, notConnected];
}
