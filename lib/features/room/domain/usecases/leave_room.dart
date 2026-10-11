import '../entities/entity_snapshot.dart';
import '../entities/leave_room_report.dart';
import '../services/room_controller.dart';

/// App-initiated "Leave room": switches off the room's selected,
/// controllable entities — never anything else in the installation —
/// and reports each device's outcome.
///
/// It only runs while the app runs. Scheduled or sensor-triggered
/// behaviour belongs in a Home Assistant automation.
class LeaveRoom {
  const LeaveRoom(this._room);

  final RoomController _room;

  Future<LeaveRoomReport> call() async {
    final view = _room.current;
    final targets = view.devices.where(
      (d) => d.snapshot?.kind.isControllable ?? false,
    );

    if (!view.connection.isConnected) {
      return LeaveRoomReport([
        for (final d in targets)
          LeaveRoomEntry(d.id, d.snapshot!.name, LeaveOutcome.skipped),
      ], notConnected: true);
    }

    final entries = await Future.wait(
      targets.map((d) async {
        final s = d.snapshot!;
        if (d.isRemoved || s.value is! OnOffValue) {
          return LeaveRoomEntry(d.id, s.name, LeaveOutcome.skipped);
        }
        if (s.isOn == false && !d.isPending) {
          return LeaveRoomEntry(d.id, s.name, LeaveOutcome.alreadyOff);
        }
        final outcome = await _room.setPower(d.id, on: false);
        return LeaveRoomEntry(d.id, s.name, switch (outcome) {
          CommandOutcome.confirmed => LeaveOutcome.confirmed,
          CommandOutcome.failed => LeaveOutcome.failed,
          CommandOutcome.unconfirmed => LeaveOutcome.unconfirmed,
          CommandOutcome.rejected => LeaveOutcome.skipped,
        });
      }),
    );
    return LeaveRoomReport(entries);
  }
}
