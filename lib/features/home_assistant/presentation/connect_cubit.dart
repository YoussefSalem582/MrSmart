import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../domain/ha_credentials.dart';
import '../domain/ha_endpoint.dart';
import '../domain/usecases/connect_home_assistant.dart';

enum ConnectStatus { idle, testing, success, failure }

class ConnectState extends Equatable {
  const ConnectState({
    this.status = ConnectStatus.idle,
    this.failure,
    this.info,
    this.isInsecure = false,
    this.storedAddress,
  });

  final ConnectStatus status;
  final Failure? failure;
  final HaInstanceInfo? info;

  /// The typed address uses plain HTTP.
  final bool isInsecure;

  /// Previously saved address, to prefill when reconfiguring. The token is
  /// never read back into the UI.
  final String? storedAddress;

  ConnectState copyWith({
    ConnectStatus? status,
    Failure? Function()? failure,
    HaInstanceInfo? info,
    bool? isInsecure,
    String? storedAddress,
  }) => ConnectState(
    status: status ?? this.status,
    failure: failure == null ? this.failure : failure(),
    info: info ?? this.info,
    isInsecure: isInsecure ?? this.isInsecure,
    storedAddress: storedAddress ?? this.storedAddress,
  );

  @override
  List<Object?> get props => [
    status,
    failure?.runtimeType,
    info,
    isInsecure,
    storedAddress,
  ];
}

class ConnectCubit extends Cubit<ConnectState> {
  ConnectCubit(this._connect, this._credentials) : super(const ConnectState());

  final ConnectHomeAssistant _connect;
  final CredentialsRepository _credentials;

  Future<void> load() async {
    final stored = await _credentials.read();
    if (stored != null && !isClosed) {
      final address = stored.endpoint.toString();
      emit(state.copyWith(storedAddress: address));
      addressChanged(address);
    }
  }

  void addressChanged(String address) {
    bool insecure;
    try {
      insecure = !HaEndpoint.parse(address).isSecure;
    } on Failure {
      insecure = false;
    }
    if (insecure != state.isInsecure) {
      emit(state.copyWith(isInsecure: insecure));
    }
  }

  Future<void> submit(String address, String token) async {
    emit(state.copyWith(status: ConnectStatus.testing, failure: () => null));
    try {
      final info = await _connect(address, token);
      emit(state.copyWith(status: ConnectStatus.success, info: info));
    } on Failure catch (f) {
      emit(state.copyWith(status: ConnectStatus.failure, failure: () => f));
    }
  }
}
