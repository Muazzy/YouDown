import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_video_downloader/model/video_model.dart';

class DownloadVideoScreen extends StatefulWidget {
  final VideoModel video;
  const DownloadVideoScreen({super.key, required this.video});

  @override
  State<DownloadVideoScreen> createState() => _DownloadVideoScreenState();
}

class _DownloadVideoScreenState extends State<DownloadVideoScreen> {
  bool isPermissionGranted = false;
  late String _localPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            // pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.video.id.toString(),
                child: CachedNetworkImage(
                  imageUrl: widget.video.thumbnail ?? defaultThumbnail,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            floating: true,
          ),
        ],
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Video Format',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.video.videoDownloadOptions!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        child: Text(
                          widget
                              .video.videoDownloadOptions![index].qualityLabel,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      title: Text(
                        widget.video.videoDownloadOptions![index].size
                            .toString(),
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  // color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      subtitle: Text(
                        '${widget.video.videoDownloadOptions![index].codec.subtype}: ${widget.video.videoDownloadOptions![index].bitrate}',
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          print('before $isPermissionGranted');

                          isPermissionGranted = await _checkPermission();

                          setState(() {});
                          print('after $isPermissionGranted');

                          await _prepareSaveDir();
                          setState(() {});

                          print('local path after: $_localPath');

                          print(widget.video.videoDownloadOptions![index].url);
                        },
                        icon: Icon(Icons.download),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      color: Colors.purple,
                      thickness: 2,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Audio Format',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.video.audioDownloadOptions!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        radius: 30,
                        // child: Text(
                        //   widget.video.audioDownloadOptions![index].qualityLabel,
                        //   style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        // ),
                        child: Icon(Icons.music_note),
                      ),
                      title: Text(
                        widget.video.audioDownloadOptions![index].size
                            .toString(),
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  // color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      subtitle: Text(
                        '${widget.video.audioDownloadOptions![index].codec.subtype}: ${widget.video.audioDownloadOptions![index].bitrate}',
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          print(widget.video.audioDownloadOptions![index].url);
                        },
                        icon: Icon(Icons.download),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      color: Colors.amber,
                      thickness: 2,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _getSavedDir())!;
    final savedDir = Directory(_localPath);
    if (!savedDir.existsSync()) {
      await savedDir.create();
    }
  }

  Future<String?> _getSavedDir() async {
    String? externalStorageDirPath;

    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (err, st) {
        print('failed to get downloads path: $err, $st');

        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return '$externalStorageDirPath/YouDown';
  }

  Future<bool> _checkPermission() async {
    if (Platform.isIOS) {
      return true;
    }

    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status == PermissionStatus.granted) {
        return true;
      }

      final result = await Permission.storage.request();
      return result == PermissionStatus.granted;
    }

    throw StateError('unknown platform');
  }
}
