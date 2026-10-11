import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/error/failure.dart';

/// Translates transport exceptions into domain [Failure]s.
Failure mapTransportError(Object error) {
  if (error is Failure) return error;
  if (error is DioException) return _mapDio(error);
  if (error is WebSocketChannelException && error.inner != null) {
    return mapTransportError(error.inner!);
  }
  if (error is TimeoutException) return const TimeoutFailure();
  if (error is HandshakeException || error is TlsException) {
    return const TlsFailure();
  }
  if (error is SocketException || error is HttpException) {
    return const NetworkFailure();
  }
  if (error is FormatException || error is TypeError) {
    return const ServerFailure('malformed response');
  }
  return NetworkFailure(error.runtimeType.toString());
}

Failure _mapDio(DioException e) => switch (e.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.transformTimeout => const TimeoutFailure(),
  DioExceptionType.badCertificate => const TlsFailure(),
  DioExceptionType.badResponse => switch (e.response?.statusCode) {
    401 => const AuthFailure(),
    403 => const PermissionFailure(),
    404 => const NotFoundFailure(),
    final code => ServerFailure('HTTP $code'),
  },
  DioExceptionType.cancel => const NetworkFailure('cancelled'),
  DioExceptionType.connectionError || DioExceptionType.unknown =>
    e.error == null ? const NetworkFailure() : mapTransportError(e.error!),
};
