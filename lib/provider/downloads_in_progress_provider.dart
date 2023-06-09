import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_down/model/download_task_model.dart';
import 'package:you_down/provider/downloader_provider.dart';

class NotDownloadedTaksNotifier extends Notifier<List<DownloadTaskModel>> {
  @override
  build() {
    final downloadTasks = ref.watch(downloadProvider);

    if (downloadTasks.isEmpty) {
      return [];
    }

    //remove failed tasks as well from the list.
    return downloadTasks
        .where(
          (task) =>
              task.downloadStatus != DownloadTaskStatus.complete &&
              task.downloadStatus != DownloadTaskStatus.failed,
        )
        .toList();
  }
}

final downloadsInProgressProvider =
    NotifierProvider<NotDownloadedTaksNotifier, List<DownloadTaskModel>>(
        () => NotDownloadedTaksNotifier());
