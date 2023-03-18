import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
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
  String isSelected = '';
  bool isDownloading = false;
  List<String> downloads = [];

  bool isDownloaded(String url) => downloads.contains(url);

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
                                    color: Colors.purple.shade900,
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
                      trailing: !isDownloaded(widget
                              .video.videoDownloadOptions![index].url
                              .toString())
                          ? IconButton(
                              disabledColor: Colors.grey,
                              color: Colors.purple,
                              isSelected: isSelected ==
                                  widget.video.videoDownloadOptions![index].url
                                      .toString(),
                              selectedIcon: CircularProgressIndicator(),
                              //never do this : downloadFile( widget.video.audioDownloadOptions![index], widget.video), directly cuz it will call the function before its built
                              onPressed: isDownloading
                                  ? null
                                  : () => downloadFile(
                                      widget.video.videoDownloadOptions![index],
                                      widget.video),

                              icon: Icon(
                                Icons.download,
                              ),
                            )
                          : null,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      color: Colors.purple.shade100,
                      thickness: 1,
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
                      trailing: !isDownloaded(widget
                              .video.audioDownloadOptions![index].url
                              .toString())
                          ? IconButton(
                              disabledColor: Colors.grey,
                              color: Colors.purple,
                              isSelected: isSelected ==
                                  widget.video.audioDownloadOptions![index].url
                                      .toString(),
                              selectedIcon: CircularProgressIndicator(),
                              //never do this : downloadFile( widget.video.audioDownloadOptions![index], widget.video), directly cuz it will call the function before its built
                              onPressed: isDownloading
                                  ? null
                                  : () => downloadFile(
                                      widget.video.audioDownloadOptions![index],
                                      widget.video),

                              icon: Icon(
                                Icons.download,
                              ),
                            )
                          : null,
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

  downloadFile(StreamInfo stream, VideoModel video) async {
    setState(() {
      isDownloading = true;
      isSelected = stream.url.toString();
    });

    isPermissionGranted = await _checkPermission();
    setState(() {});

    if (!isPermissionGranted) {
      setState(() {
        isDownloading = false;
        isSelected = '';
      });
      return print('permission not granted');
    }

    await _prepareSaveDir();
    setState(() {});

    bool isAudioFile = video.audioDownloadOptions!.contains(stream);

    print('isAudioFile: $isAudioFile');
    String extension = isAudioFile ? '.mp3' : '.mp4';
    String quality = isAudioFile ? '' : stream.qualityLabel;

    YoutubeExplode yt = YoutubeExplode();

    var downloadStream = yt.videos.streamsClient.get(stream);

    var file = File('$_localPath/${video.title}-$quality$extension');
    if (file.existsSync()) {
      int i = 1;
      while (file.existsSync()) {
        file = File('$_localPath/${video.title}-$quality-$i$extension');
        i++;
      }
    }
    var fileStream = file.openWrite(mode: FileMode.write);

    downloadStream.listen((eventBytes) {
      fileStream.add(eventBytes);
    }).onDone(() async {
      print(file.path);
      await fileStream.flush();
      await fileStream.close();

      setState(() {
        downloads
            .add(stream.url.toString()); //change this to the path of the file
        isDownloading = false;
        isSelected = '';
      });

      print('completed successfully');
    });
  }
}
