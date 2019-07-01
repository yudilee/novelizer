import 'dart:io';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

enum WebTaskState {
  INITIALIZED,
  QUEUED,
  PROCESSING,
  SENDING,
  RECEIVING,
  CANCELLED,
  FAILED,
  FINISHED,
}

class WebTask<T> {
  final DateTime createdAt;
  final dynamic data;
  final String uri;
  final String group;
  final String method;
  final File savePath;
  final ResponseType type;
  final CancelToken cancelToken;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> queryParameters;

  T result;
  String error;
  int total = 0;
  int progress = 0;
  WebTaskState state;

  WebTask({
    this.data,
    this.savePath,
    this.method = "get",
    @required this.uri,
    @required this.group,
    this.type = ResponseType.plain,
    CancelToken customCancelToken,
    this.headers = const {},
    this.queryParameters = const {},
  })  : createdAt = DateTime.now(),
        state = WebTaskState.INITIALIZED,
        cancelToken = customCancelToken ?? CancelToken();

  double get percent => total > 0 ? progress * 100.0 / total : 0;
  String get percentString => percent.toStringAsFixed(2) + '%';

  @override
  int get hashCode => [uri, group, createdAt].hashCode;

  @override
  bool operator ==(other) =>
      other is WebTask &&
      other.uri == uri &&
      other.createdAt == createdAt &&
      other.group == group;

  void onProgress(int count, int total) {
    this.total = total;
    this.progress = count;
  }
}
