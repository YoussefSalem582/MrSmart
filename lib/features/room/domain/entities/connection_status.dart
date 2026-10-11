import 'package:equatable/equatable.dart';

enum ConnectionPhase {
  connecting,
  connected,
  reconnecting,
  disconnected,
  authFailed,
}

class ConnectionStatus extends Equatable {
  const ConnectionStatus(this.phase, {this.attempt = 0, this.retryIn});

  const ConnectionStatus.connecting() : this(ConnectionPhase.connecting);
  const ConnectionStatus.connected() : this(ConnectionPhase.connected);
  const ConnectionStatus.disconnected() : this(ConnectionPhase.disconnected);
  const ConnectionStatus.authFailed() : this(ConnectionPhase.authFailed);

  final ConnectionPhase phase;

  /// Reconnect attempt number (1-based) while [ConnectionPhase.reconnecting].
  final int attempt;
  final Duration? retryIn;

  bool get isConnected => phase == ConnectionPhase.connected;

  @override
  List<Object?> get props => [phase, attempt, retryIn];
}
