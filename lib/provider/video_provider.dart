import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_down/model/video_model.dart';
import 'package:you_down/utils/main_utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoNotifier extends AsyncNotifier<dynamic> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<dynamic> getVideo(String url) async {
    state = const AsyncLoading();

    if (url.isEmpty) {
      state = AsyncError('Empty Url', StackTrace.current);
      return AsyncError('Empty Url', StackTrace.current);
    }

    final videoId = MainUtils.getVideoID(url);
    if (videoId.isEmpty) {
      state = AsyncError('Invalid Url', StackTrace.current);
      return AsyncError('Invalid Url', StackTrace.current);
    }

    YoutubeExplode yt = YoutubeExplode();

    state = await AsyncValue.guard(() async {
      Video video = await yt.videos.get(videoId);
      if (video.isLive) {
        state =
            AsyncError('live vidoes can not be downloaded', StackTrace.current);
        return AsyncError(
            'live vidoes can not be downloaded', StackTrace.current);
      }
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      yt.close();
      return VideoModel.fromVideo(video, manifest);
    });
  }
}

final videoProvider = AsyncNotifierProvider(() => VideoNotifier());
