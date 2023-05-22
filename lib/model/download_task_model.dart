import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadTaskModel {
  final String link;
  final String? downloadTaskId;
  int? progress;
  final String fileName;
  final String? imgUrl;
  final bool isAudio;

  DownloadTaskStatus downloadStatus;

  DownloadTaskModel({
    required this.isAudio,
    required this.fileName,
    required this.link,
    required this.imgUrl,
    this.downloadTaskId,
    this.downloadStatus = DownloadTaskStatus.undefined,
    this.progress = 0,
  });

  DownloadTaskModel copyWith(
      {String? link,
      String? downloadTaskId,
      int? progress,
      DownloadTaskStatus? downloadStatus,
      String? fileName,
      String? imgUrl,
      bool? isAudio}) {
    return DownloadTaskModel(
      isAudio: isAudio ?? this.isAudio,
      imgUrl: imgUrl ?? this.imgUrl,
      fileName: fileName ?? this.fileName,
      link: link ?? this.link,
      downloadTaskId: downloadTaskId ?? this.downloadTaskId,
      progress: progress ?? this.progress,
      downloadStatus: downloadStatus ?? this.downloadStatus,
    );
  }
}
