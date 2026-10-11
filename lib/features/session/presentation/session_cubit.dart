import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/logging/app_logger.dart';
import '../../home_assistant/domain/ha_credentials.dart';
import '../../home_assistant/domain/usecases/erase_home_assistant.dart';
import '../domain/app_mode.dart';

class SessionState extends Equatable {
  const SessionState({
    this.mode = AppMode.none,
    this.restored = false,
    this.epoch = 0,
    this.hasStoredCredentials = false,
  });

  final AppMode mode;

  /// False until the persisted mode has been reopened at startup.
  final bool restored;

  /// Bumped whenever the session graph is rebuilt; screens key on it.
  final int epoch;

  /// Home Assistant credentials exist in secure storage.
  final bool hasStoredCredentials;

  SessionState copyWith({
    AppMode? mode,
    bool? restored,
    int? epoch,
    bool? hasStoredCredentials,
  }) => SessionState(
    mode: mode ?? this.mode,
    restored: restored ?? this.restored,
    epoch: epoch ?? this.epoch,
    hasStoredCredentials: hasStoredCredentials ?? this.hasStoredCredentials,
  );

  @override
  List<Object?> get props => [mode, restored, epoch, hasStoredCredentials];
}

/// Which mode is active. Switching closes the previous mode's scope first,
/// so no subscription outlives its mode.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._scope, this._modes, this._credentials, this._erase)
    : super(const SessionState());

  final SessionScope _scope;
  final AppModeRepository _modes;
  final CredentialsRepository _credentials;
  final EraseHomeAssistant _erase;

  Future<void> restore() async {
    try {
      await _open(_modes.read());
    } on Exception catch (e) {
      AppLogger.warning('Could not restore session: $e');
      await _open(AppMode.none);
    }
    emit(state.copyWith(restored: true));
  }

  Future<void> startDemo() => _open(AppMode.demo);

  /// Reopens with the credentials just saved by the connect flow.
  Future<void> startHomeAssistant() => _open(AppMode.homeAssistant);

  /// Back to the welcome screen. Stored credentials are kept.
  Future<void> exit() => _open(AppMode.none);

  Future<void> roomSelectionChanged() async {
    await _scope.resetRoom();
    emit(state.copyWith(epoch: state.epoch + 1));
  }

  /// Closes any Home Assistant session, then deletes the address, token
  /// and room selection from this device.
  Future<void> disconnectAndErase() async {
    if (state.mode == AppMode.homeAssistant) await _open(AppMode.none);
    await _erase();
    emit(state.copyWith(hasStoredCredentials: false));
  }

  Future<void> _open(AppMode mode) async {
    await _scope.close();
    if (mode != AppMode.none) await _scope.open(mode);
    await _modes.save(mode);
    emit(
      state.copyWith(
        mode: mode,
        epoch: state.epoch + 1,
        hasStoredCredentials: await _credentials.read() != null,
      ),
    );
  }
}
