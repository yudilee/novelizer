import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'bloc_provider.dart';
import '../models/web_task.dart';
import '../tools/user_agents.dart';

class DownloaderBloc extends BlocBase {
  static final int maxConcurrentJobs = 20;
  static final int concurrentJobsPerGroup = 5;

  static DownloaderBloc of(BuildContext context) => BlocProvider.of(context);

  // ------------------------------------------------------------------------------------------- //

  final _dio = Dio();
  final _queue = PublishSubject<WebTask>();
  final _tasks = Map<String, Set<WebTask>>();
  StreamSubscription _queueListener;

  @override
  void initState(BuildContext context) {
    _dio.interceptors.add(CookieManager(PersistCookieJar()));
    _dio.options.headers.putIfAbsent('User-Agent', pickRandomUserAgent);
    _startQueue();
  }

  @override
  void dispose() async {
    _dio.clear();
    _tasks.clear();
    await Future.wait([
      _queue.close(),
      _queueListener.cancel(),
    ]);
  }

  // ------------------------------------------------------------------------------------------- //

  Observable<WebTask> fetch(WebTask task) {
    // add watcher for cancel events
    task?.cancelToken?.whenCancel?.then((_) {
      task.state = WebTaskState.CANCELLED;
      _queue.sink.add(task);
    });
    // add task to queue
    _queue.sink.add(task);
    // return the task state observable
    return _queue.stream.where((t) => t == task);
  }

  Observable<WebTask> fetchHtml(String uri, {String group}) {
    return fetch(WebTask<Document>(
      uri: uri,
      type: ResponseType.plain,
      group: group ?? Uri.parse(uri).origin,
    ));
  }

  Observable<WebTask> fetchJson(String uri, {String group}) {
    return fetch(WebTask<Map<String, dynamic>>(
      uri: uri,
      type: ResponseType.json,
      group: group ?? Uri.parse(uri).origin,
    ));
  }

  Observable<WebTask> download(String uri, File saveTo, {String group}) {
    return fetch(WebTask(
      uri: uri,
      savePath: saveTo,
      method: 'download',
      type: ResponseType.bytes,
      group: group ?? Uri.parse(uri).origin,
    ));
  }

  void changeUserAgent() {
    _dio.options.headers['User-Agent'] = pickRandomUserAgent();
  }

  // ------------------------------------------------------------------------------------------- //

  void _startQueue() {
    _queueListener = _queue.listen((task) {
      switch (task.state) {
        case WebTaskState.INITIALIZED:
          // add new task to the queue
          task.state = WebTaskState.QUEUED;
          _tasks.putIfAbsent(task.group, () => Set());
          _tasks[task.group].add(task);
          _queue.sink.add(task);
          break;
        case WebTaskState.QUEUED:
          // when a task is on queue
          if (_tasks.keys.length < maxConcurrentJobs &&
              _tasks[task.group].length < concurrentJobsPerGroup) {
            // start processing task if max concurrent job limit is satisfied
            task.state = WebTaskState.PROCESSING;
            _queue.sink.add(task);
          } else {
            // otherwise delay processing task for a small duration
            Future.delayed(
              Duration(milliseconds: 300),
              () => _queue.sink.add(task),
            );
          }
          break;
        case WebTaskState.PROCESSING:
          // do the actual download task
          _processTask(task);
          break;
        case WebTaskState.SENDING:
        case WebTaskState.RECEIVING:
          // task is running. do nothing.
          break;
        case WebTaskState.FAILED:
        case WebTaskState.FINISHED:
        case WebTaskState.CANCELLED:
          // remove task from the list when finished
          _tasks[task.group].remove(task);
          // remove the whole group if empty
          if (_tasks[task.group].isEmpty) {
            _tasks.remove(task.group);
          }
          break;
      }
    });
  }

  void _processTask(WebTask task) {
    final onReceiveProgress = (count, total) {
      task.progress = count;
      task.total = total;
      task.state = WebTaskState.RECEIVING;
      _queue.sink.add(task);
    };

    final onSendProgress = (count, total) {
      task.progress = count;
      task.total = total;
      task.state = WebTaskState.SENDING;
      _queue.sink.add(task);
    };

    final options = Options(
      method: task.method,
      headers: task.headers,
      responseType: task.type,
      receiveDataWhenStatusError: false,
    );

    final onResult = (Response result) {
      task.state = WebTaskState.FINISHED;
      if (task.result is Document) {
        task.result = HtmlParser(
          result.data,
          encoding: 'utf8',
          sourceUrl: task.uri,
        ).parse();
      } else {
        task.result = result.data;
      }
      _queue.sink.add(task);
    };

    final onError = (error) {
      task.state = WebTaskState.FAILED;
      task.error = '$error';
      _queue.sink.add(task);
    };

    if (task.savePath != null) {
      _dio
          .download(
            task.uri,
            task.savePath,
            data: task.data,
            options: options,
            cancelToken: task.cancelToken,
            queryParameters: task.queryParameters,
            onReceiveProgress: onReceiveProgress,
          )
          .then(onResult)
          .catchError(onError);
    } else {
      _dio
          .request(
            task.uri,
            data: task.data,
            options: options,
            queryParameters: task.queryParameters,
            cancelToken: task.cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .then(onResult)
          .catchError(onError);
    }
  }
}
