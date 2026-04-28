import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Builds a [DioException] with the given status code and body, as Dio would
/// produce one when the server replies with a non-2xx response.
DioException dioException({
  required int statusCode,
  Object? body,
  String path = '/test',
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  final options = RequestOptions(path: path);
  return DioException(
    requestOptions: options,
    type: type,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: statusCode,
      data: body,
    ),
  );
}

/// Builds a [DioException] for connection-level failures (no response).
DioException dioConnectionError({
  String path = '/test',
  DioExceptionType type = DioExceptionType.connectionError,
}) =>
    DioException(
      requestOptions: RequestOptions(path: path),
      type: type,
    );

/// Minimal scriptable [HttpClientAdapter] for full-stack tests of [Dio]
/// pipelines (interceptors, error handling). Each call to [respond] queues
/// a single response that the next request will receive.
class FakeHttpClientAdapter implements HttpClientAdapter {
  final List<_Scripted> _queue = [];
  final List<RequestOptions> requests = [];

  void respond({
    int statusCode = 200,
    Object? body,
  }) {
    _queue.add(_Scripted(statusCode: statusCode, body: body));
  }

  /// Asserts the queue is empty — useful in `tearDown` to make sure tests
  /// consumed every scripted response.
  void verifyDrained() {
    if (_queue.isNotEmpty) {
      throw StateError('FakeHttpClientAdapter has ${_queue.length} unused responses.');
    }
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_queue.isEmpty) {
      throw StateError('No scripted response for ${options.method} ${options.path}');
    }
    final scripted = _queue.removeAt(0);
    final bytes = scripted.body == null
        ? <int>[]
        : utf8.encode(jsonEncode(scripted.body));
    return ResponseBody.fromBytes(
      bytes,
      scripted.statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Scripted {
  final int statusCode;
  final Object? body;
  _Scripted({required this.statusCode, this.body});
}
