import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/leave_room_report.dart';
import '../../domain/entities/room_view.dart';
import '../../domain/repositories/demo_controls.dart';
import '../../domain/services/room_controller.dart';
import '../../domain/usecases/leave_room.dart';

class RoomUiState extends Equatable {
  const RoomUiState({
    required this.view,
    this.isLeaving = false,
    this.leaveReport,
  });

  final RoomView view;
  final bool isLeaving;
  final LeaveRoomReport? leaveReport;

  RoomUiState copyWith({
    RoomView? view,
    bool? isLeaving,
    LeaveRoomReport? Function()? leaveReport,
  }) => RoomUiState(
    view: view ?? this.view,
    isLeaving: isLeaving ?? this.isLeaving,
    leaveReport: leaveReport == null ? this.leaveReport : leaveReport(),
  );

  @override
  List<Object?> get props => [view, isLeaving, leaveReport];
}

/// UI adapter over [RoomController]. Holds no device logic of its own.
class RoomCubit extends Cubit<RoomUiState> {
  RoomCubit(this._room, this._leaveRoom, {this.demo})
    : super(RoomUiState(view: _room.current));

  final RoomController _room;
  final LeaveRoom _leaveRoom;

  /// Present only in demo mode.
  final DemoControls? demo;

  StreamSubscription<RoomView>? _sub;

  Future<void> start() async {
    _sub ??= _room.view.listen((v) => emit(state.copyWith(view: v)));
    emit(state.copyWith(view: _room.current));
    await _room.start();
  }

  bool canControl(String entityId) => _room.canControl(entityId);

  /// Fire-and-forget: progress is reported through [state].
  void toggle(String entityId) {
    final isOn = state.view.device(entityId)?.snapshot?.isOn;
    if (isOn == null) return;
    unawaited(_room.setPower(entityId, on: !isOn));
  }

  Future<void> leaveRoom() async {
    emit(state.copyWith(isLeaving: true, leaveReport: () => null));
    final report = await _leaveRoom();
    if (!isClosed) {
      emit(state.copyWith(isLeaving: false, leaveReport: () => report));
    }
  }

  void clearLeaveReport() => emit(state.copyWith(leaveReport: () => null));

  Future<void> pause() => _room.pause();

  Future<void> resume() => _room.resume();

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
