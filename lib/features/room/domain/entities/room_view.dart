import 'package:equatable/equatable.dart';

import 'connection_status.dart';
import 'entity_snapshot.dart';
import '../../../../core/error/failure.dart';

/// Lifecycle of the latest command sent to one device.
sealed class CommandState extends Equatable {
  const CommandState(this.targetOn);
  final bool targetOn;

  @override
  List<Object?> get props => [targetOn];
}

/// Sent (or being sent); waiting for the source to report the target state.
final class CommandPending extends CommandState {
  const CommandPending(super.targetOn, this.startedAt);
  final DateTime startedAt;

  @override
  List<Object?> get props => [targetOn, startedAt];
}

/// The request itself was rejected or could not be delivered.
final class CommandFailed extends CommandState {
  const CommandFailed(super.targetOn, this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [targetOn, failure.runtimeType];
}

enum UnconfirmedReason { timeout, connectionLost }

/// The request may have been accepted, but the target state was never
/// observed. Shown as a warning, never as success.
final class CommandUnconfirmed extends CommandState {
  const CommandUnconfirmed(super.targetOn, this.reason);
  final UnconfirmedReason reason;

  @override
  List<Object?> get props => [targetOn, reason];
}

/// Everything the UI knows about one selected entity.
class DeviceState extends Equatable {
  const DeviceState({
    required this.id,
    this.snapshot,
    this.lastConfirmedAt,
    this.isStale = false,
    this.isRemoved = false,
    this.command,
  });

  final String id;

  /// Last state the source confirmed. Null until the first read.
  final EntitySnapshot? snapshot;
  final DateTime? lastConfirmedAt;

  /// True while offline: [snapshot] is the last known value, not live.
  final bool isStale;

  /// The entity no longer exists at the source.
  final bool isRemoved;
  final CommandState? command;

  bool get isPending => command is CommandPending;

  DeviceState copyWith({
    EntitySnapshot? snapshot,
    DateTime? lastConfirmedAt,
    bool? isStale,
    bool? isRemoved,
    CommandState? Function()? command,
  }) => DeviceState(
    id: id,
    snapshot: snapshot ?? this.snapshot,
    lastConfirmedAt: lastConfirmedAt ?? this.lastConfirmedAt,
    isStale: isStale ?? this.isStale,
    isRemoved: isRemoved ?? this.isRemoved,
    command: command == null ? this.command : command(),
  );

  @override
  List<Object?> get props => [
    id,
    snapshot,
    lastConfirmedAt,
    isStale,
    isRemoved,
    command,
  ];
}

enum ActivityType {
  commandSent,
  confirmed,
  failed,
  unconfirmed,
  externalChange,
  becameUnavailable,
  removed,
  connectionLost,
  reconnected,
}

class ActivityItem extends Equatable {
  const ActivityItem({
    required this.at,
    required this.type,
    this.deviceName,
    this.targetOn,
    this.value,
  });

  final DateTime at;
  final ActivityType type;
  final String? deviceName;
  final bool? targetOn;
  final EntityValue? value;

  @override
  List<Object?> get props => [at, type, deviceName, targetOn, value];
}

class RoomView extends Equatable {
  const RoomView({
    required this.connection,
    required this.devices,
    this.isLoading = true,
    this.activity = const [],
  });

  final ConnectionStatus connection;

  /// In the order the user selected them.
  final List<DeviceState> devices;
  final bool isLoading;

  /// Newest first, capped.
  final List<ActivityItem> activity;

  DeviceState? device(String id) {
    for (final d in devices) {
      if (d.id == id) return d;
    }
    return null;
  }

  RoomView copyWith({
    ConnectionStatus? connection,
    List<DeviceState>? devices,
    bool? isLoading,
    List<ActivityItem>? activity,
  }) => RoomView(
    connection: connection ?? this.connection,
    devices: devices ?? this.devices,
    isLoading: isLoading ?? this.isLoading,
    activity: activity ?? this.activity,
  );

  @override
  List<Object?> get props => [connection, devices, isLoading, activity];
}
