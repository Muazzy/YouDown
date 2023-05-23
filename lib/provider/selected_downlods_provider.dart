import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_down/model/download_task_model.dart';
import 'package:you_down/model/video_model.dart';
import 'package:you_down/provider/directory_provider.dart';
import 'package:you_down/provider/downloader_provider.dart';
import 'package:you_down/provider/get_file_name_provider.dart';
import 'package:you_down/utils/main_utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SelectedDownloadsNotifier extends Notifier<List<StreamInfo>> {
  @override
  build() {
    return [];
  }

  void select(StreamInfo stream) {
    state = [...state, stream];
  }

  void unSelect(StreamInfo currentStream) {
    state = [
      for (final stream in state)
        if (stream.url != currentStream.url) stream,
    ];
  }

  void reset() {
    state.clear();
  }

  Future<void> addToDownloader(VideoModel video) async {
    final bool isSdkAbove29 = await MainUtils.isSdkAbove29();
    List<DownloadTaskModel> tasks = [];

    for (var stream in state) {
      final bool isAudio = video.audioDownloadOptions!.contains(stream);
      final dir = await ref.watch(dirProvider([isSdkAbove29, isAudio])
          .future); // use .future with await to get actual value.

      if (dir.isEmpty) {
        return;
      }

      final fileName = await ref
          .watch(getFileNameProvider([video, stream, isAudio, dir]).future);

      final taskId = await FlutterDownloader.enqueue(
        url: stream.url.toString(),
        savedDir: dir,
        showNotification: true,
        openFileFromNotification: true,
        fileName: fileName,
      );

      // print(taskId);
      final downloadTask = DownloadTaskModel(
        fileName: fileName,
        link: stream.url.toString(),
        downloadTaskId: taskId,
        imgUrl: video.thumbnail,
        isAudio: isAudio,
      );

      tasks.add(downloadTask);
    }

    ref.read(downloadProvider.notifier).addDownloads(tasks);
  }
}

final selectedDownloadsProvider =
    NotifierProvider<SelectedDownloadsNotifier, List<StreamInfo>>(
  () => SelectedDownloadsNotifier(),
);

final isSelectedProvider = Provider.family<bool, StreamInfo>((
  ref,
  currentStream,
) {
  final selectedVideos = ref.watch(selectedDownloadsProvider);

  for (StreamInfo stream in selectedVideos) {
    if (currentStream.url == stream.url) {
      return true;
    }
  }
  return false;
});
