import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'ha_failure_mapper.dart';

/// Minimal text socket, so [HaSocket] can be tested without a network.
abstract interface class HaWsTransport {
  /// Single-subscription stream of text frames.
  Stream<String> get messages;
  void send(String data);
  Future<void> close();
}

typedef HaWsConnector = Future<HaWsTransport> Function(Uri uri);

class WebSocketChannelTransport implements HaWsTransport {
  WebSocketChannelTransport._(this._channel);

  static Future<HaWsTransport> connect(
    Uri uri, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final channel = WebSocketChannel.connect(uri);
    try {
      await channel.ready.timeout(timeout);
    } catch (e) {
      unawaited(channel.sink.close());
      throw mapTransportError(e);
    }
    return WebSocketChannelTransport._(channel);
  }

  final WebSocketChannel _channel;

  @override
  Stream<String> get messages =>
      _channel.stream.where((m) => m is String).cast<String>();

  @override
  void send(String data) => _channel.sink.add(data);

  @override
  Future<void> close() async => _channel.sink.close();
}
