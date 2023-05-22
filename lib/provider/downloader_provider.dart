import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_down/model/download_task_model.dart';
import 'package:you_down/provider/files_provider.dart';

class DownloaderNotifier extends Notifier<List<DownloadTaskModel>> {
  @override
  List<DownloadTaskModel> build() {
    return [];
  }

  void addDownloads(List<DownloadTaskModel> selected) {
    state = [...state, ...selected];
  }

  void pause(String taskId) {
    FlutterDownloader.pause(taskId: taskId);
    _updateStatus(taskId, DownloadTaskStatus.paused);
  }

  void resume(String taskId) {
    FlutterDownloader.resume(taskId: taskId);
    _updateStatus(taskId, DownloadTaskStatus.running);
  }

  void retry(String taskId) {
    FlutterDownloader.retry(taskId: taskId);
    _updateStatus(taskId, DownloadTaskStatus.running);
  }

  void cancel(String taskId) {
    FlutterDownloader.remove(
      taskId: taskId,
      shouldDeleteContent: true,
    );
    // _updateStatus(taskId, status)
    _deleteTask(taskId);
  }

  void _deleteTask(String taskId) {
    // state.removeWhere((task) => task.downloadTaskId == taskId); //this won't work cuz our state is immutable & we can't change it, however we can assign it to something else.
    state = [
      for (final task in state)
        if (task.downloadTaskId != taskId) task,
    ];
  }

  void _updateStatus(String taskId, DownloadTaskStatus status) {
    state = [
      for (final downloadTask in state)
        if (downloadTask.downloadTaskId == taskId)
          downloadTask.copyWith(downloadStatus: status)
        else
          downloadTask,
    ];
  }

  void updateTask(String taskId, int progress, DownloadTaskStatus status) {
    state = [
      for (final downloadTask in state)
        if (downloadTask.downloadTaskId == taskId)
          downloadTask.copyWith(downloadStatus: status, progress: progress)
        else
          downloadTask,
    ];

    if (status == DownloadTaskStatus.complete) {
      ref.read(fileProvider.notifier).refreshFiles();
    }
  }

  //init & dispose methods to update the state of downloadTasks

  final ReceivePort _port = ReceivePort();
  Isolate? _isolate;

  bool _isListening = false; //to know if the _port has already been litsened to

  void initialize() {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback, step: 1);
  }

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    if (!_isListening) {
      _port.listen((dynamic data) {
        final taskId = (data as List<dynamic>)[0] as String;
        final status = DownloadTaskStatus(data[1] as int);
        final progress = data[2] as int;

        // print(
        //   'Callback on UI isolate: '
        //   'task ($taskId) is in status ($status) and process ($progress)',
        // );

        if (state.isNotEmpty) {
          updateTask(taskId, progress, status);
        }
      });
      _isListening = true;
    }
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.send([id, status, progress]);
  }

  void dispose() {
    _unbindBackgroundIsolate();
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    //TODO: extra lines not mentioned in the original implementation
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }
}

final downloadProvider =
    NotifierProvider<DownloaderNotifier, List<DownloadTaskModel>>(() {
  return DownloaderNotifier();
});
