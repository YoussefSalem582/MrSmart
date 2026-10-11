import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';

/// A normalized Home Assistant base address.
///
/// Accepts what people paste: with or without scheme, trailing slashes,
/// `/api`, `/api/websocket`, or a `ws(s)://` URL. A missing scheme means
/// `https`. REST uses `http(s)`; the WebSocket uses the matching `ws(s)`.
class HaEndpoint extends Equatable {
  const HaEndpoint._(this.base);

  factory HaEndpoint.parse(String input) {
    var text = input.trim();
    if (text.isEmpty) throw const InvalidUrlFailure('empty');
    if (!text.contains('://')) text = 'https://$text';
    final uri = Uri.tryParse(text);
    if (uri == null || uri.host.isEmpty) {
      throw const InvalidUrlFailure('no host');
    }
    if (uri.userInfo.isNotEmpty) {
      throw const InvalidUrlFailure('credentials in URL');
    }
    final scheme = switch (uri.scheme.toLowerCase()) {
      'http' || 'ws' => 'http',
      'https' || 'wss' => 'https',
      _ => throw const InvalidUrlFailure('unsupported scheme'),
    };
    var path = uri.path.replaceAll(RegExp(r'/+$'), '');
    for (final suffix in ['/api/websocket', '/api']) {
      if (path.endsWith(suffix)) {
        path = path.substring(0, path.length - suffix.length);
        break;
      }
    }
    return HaEndpoint._(
      Uri(
        scheme: scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        path: path.replaceAll(RegExp(r'/+$'), ''),
      ),
    );
  }

  /// `http(s)://host[:port][/prefix]` with no trailing slash.
  final Uri base;

  /// HTTP is unencrypted: the token travels in clear text.
  bool get isSecure => base.scheme == 'https';

  /// Dio base URL, with trailing slash so relative paths append.
  Uri get restBase => base.replace(path: '${base.path}/api/');

  Uri get websocket => base.replace(
    scheme: isSecure ? 'wss' : 'ws',
    path: '${base.path}/api/websocket',
  );

  @override
  String toString() => base.toString();

  @override
  List<Object?> get props => [base];
}
