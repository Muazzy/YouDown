import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_down/model/video_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// args: [video, stream, isAudio, localPath]
final getFileNameProvider =
    FutureProvider.family<String, List<dynamic>>((ref, args) async {
  final VideoModel video = args[0];
  final StreamInfo stream = args[1];
  final bool isAudioFile = args[2];
  final String localPath = args[3];

  String baseFileName = video.title ?? 'untitled';

  String extension = isAudioFile ? '.mp3' : '.mp4';

  String quality = isAudioFile ? '' : '-${stream.qualityLabel}';

  String fileName = isAudioFile ? baseFileName : '$baseFileName$quality';
  fileName += extension;

  // Check if the file already exists
  File file = File('$localPath/$fileName');
  int i = 1;
  while (file.existsSync()) {
    fileName = isAudioFile
        ? '$baseFileName-$i$extension'
        : '$baseFileName$quality-$i$extension';
    file = File('$localPath/$fileName');
    i++;
  }

  return fileName;
});
