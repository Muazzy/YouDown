import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoModel {
  String? title;
  String? author;
  List<StreamInfo>? videoDownloadOptions;
  List<StreamInfo>? audioDownloadOptions;
  String? duration;
  String? thumbnail;
  String? id;
  Map<String, String>? paths;

  VideoModel({
    this.title = '',
    this.author = '',
    this.videoDownloadOptions = const [],
    this.duration = '',
    this.thumbnail = defaultThumbnail,
    this.audioDownloadOptions = const [],
    this.id = '',
    this.paths = const <String, String>{},
  });

  VideoModel.fromVideo(Video video, StreamManifest manifest) {
    author = video.author;
    title = video.title;
    duration = getDurationString(video.duration ?? const Duration(seconds: 0));
    videoDownloadOptions = manifest.muxed.sortByVideoQuality();
    audioDownloadOptions = manifest.audioOnly.sortByBitrate().sublist(0, 1);
    thumbnail = video.thumbnails.mediumResUrl;
    id = video.id.value;
    paths = <String, String>{};
  }
}

//TODO: filter these audio and videolists. only keep one from each quality tag i.e 720p etc and choose the one with highest bitrate.
// in audiolist. only provide one or max 2 options. if only one then select the one with highest bitrate. otherwise do the same as video but instead of qualitytag, choose subtype to filter.

const String defaultThumbnail =
    'https://www.pngfind.com/pngs/m/676-6764065_default-profile-picture-transparent-hd-png-download.png';

getDurationString(Duration duration) {
  int totalTimeinseconds = duration.inSeconds;

  int totalHours = totalTimeinseconds ~/ 3600;

  int totalRemainingTimeMinusTheHours = totalTimeinseconds % 3600;

  int totalMinutes = totalRemainingTimeMinusTheHours ~/ 60;
  int totalSeconds = totalRemainingTimeMinusTheHours % 60;

  // if (remainingSeconds == 0) {
  //   return '${totalMinutes}m';
  // } else if (totalMinutes == 0) {
  //   return '${remainingSeconds}s';
  // } else if (remainingSeconds == 0 && totalMinutes == 0) {
  //   return 'N/A';
  // } else {
  //   return '$totalMinutes:$remainingSeconds';
  // }

  if (totalHours == 0) {
    return '$totalMinutes:$totalSeconds';
  } else {
    return '$totalHours:$totalMinutes:$totalSeconds';
  }
}
