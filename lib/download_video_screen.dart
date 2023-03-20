import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_video_downloader/model/video_model.dart';
import 'package:youtube_video_downloader/widgets/custom_list_tile.dart';

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
  double? progress;
  String? progressString;
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
                    return CustomListTile(
                      stream: widget.video.videoDownloadOptions![index],
                      isSelected: isSelected ==
                          widget.video.videoDownloadOptions![index].url
                              .toString(),
                      isDownloaded: isDownloaded(widget
                          .video.videoDownloadOptions![index].url
                          .toString()),
                      progressString: progressString ?? '0%',
                      isDownloading: isDownloading,
                      onDownload: () => downloadFile(
                        widget.video.videoDownloadOptions![index],
                        widget.video,
                      ),
                    );
                    // return ListTile(
                    //   leading: CircleAvatar(
                    //     radius: 30,
                    //     child: Text(
                    //       widget
                    //           .video.videoDownloadOptions![index].qualityLabel,
                    //       style:
                    //           Theme.of(context).textTheme.bodySmall!.copyWith(
                    //                 color: Colors.purple.shade900,
                    //                 fontWeight: FontWeight.bold,
                    //               ),
                    //     ),
                    //   ),
                    //   title: Text(
                    //     widget.video.videoDownloadOptions![index].size
                    //         .toString(),
                    //     style:
                    //         Theme.of(context).textTheme.titleMedium!.copyWith(
                    //               // color: Colors.white,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //   ),
                    //   subtitle: Text(
                    //     '${widget.video.videoDownloadOptions![index].codec.subtype}: ${widget.video.videoDownloadOptions![index].bitrate}',
                    //   ),
                    //   trailing: !isDownloaded(widget
                    //           .video.videoDownloadOptions![index].url
                    //           .toString())
                    //       ? IconButton(
                    //           disabledColor: Colors.grey,
                    //           color: Colors.purple,
                    //           isSelected: isSelected ==
                    //               widget.video.videoDownloadOptions![index].url
                    //                   .toString(),
                    //           selectedIcon: Stack(
                    //             alignment: Alignment.center,
                    //             children: [
                    //               Transform.scale(
                    //                 scale: 1.5,
                    //                 child: const CircularProgressIndicator(
                    //                   strokeWidth: 0.5,
                    //                   backgroundColor: Colors.transparent,
                    //                 ),
                    //               ),
                    //               Text(
                    //                 progressString ?? '0%',
                    //                 textAlign: TextAlign.center,
                    //                 style:
                    //                     Theme.of(context).textTheme.labelSmall,
                    //               ),
                    //             ],
                    //           ),
                    //           //never do this : downloadFile( widget.video.audioDownloadOptions![index], widget.video), directly cuz it will call the function before its built
                    //           onPressed: isDownloading
                    //               ? null
                    //               : () => downloadFile(
                    //                   widget.video.videoDownloadOptions![index],
                    //                   widget.video),

                    //           icon: const Icon(
                    //             Icons.download,
                    //           ),
                    //         )
                    //       : const Icon(Icons.download_done,
                    //           color: Colors.green),
                    // );
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
                    return CustomListTile(
                      stream: widget.video.audioDownloadOptions![index],
                      isSelected: isSelected ==
                          widget.video.audioDownloadOptions![index].url
                              .toString(),
                      isDownloaded: isDownloaded(
                        widget.video.audioDownloadOptions![index].url
                            .toString(),
                      ),
                      progressString: progressString ?? '0%',
                      isDownloading: isDownloading,
                      onDownload: () => downloadFile(
                        widget.video.audioDownloadOptions![index],
                        widget.video,
                      ),
                    );
                    // return ListTile(
                    //   leading: const CircleAvatar(
                    //     radius: 30,
                    //     child: Icon(Icons.music_note),
                    //   ),
                    //   title: Text(
                    //     widget.video.audioDownloadOptions![index].size
                    //         .toString(),
                    //     style:
                    //         Theme.of(context).textTheme.titleMedium!.copyWith(
                    //               // color: Colors.white,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //   ),
                    //   subtitle: Text(
                    //     '${widget.video.audioDownloadOptions![index].codec.subtype}: ${widget.video.audioDownloadOptions![index].bitrate}',
                    //   ),
                    //   trailing: !isDownloaded(widget
                    //           .video.audioDownloadOptions![index].url
                    //           .toString())
                    //       ? IconButton(
                    //           disabledColor: Colors.grey,
                    //           color: Colors.purple,
                    //           // isSelected: isSelected ==
                    //           //     widget.video.audioDownloadOptions![index].url
                    //           //         .toString(),
                    //           isSelected: true,
                    //           selectedIcon: Stack(
                    //             alignment: Alignment.center,
                    //             // mainAxisAlignment: MainAxisAlignment.end,
                    //             children: [
                    //               Text(progressString ?? '0%'),
                    //               //TODO: will have to increase this
                    //               const SizedBox(
                    //                 height: 50,
                    //                 width: 50,
                    //                 child: CircularProgressIndicator(
                    //                   // value: ,
                    //                   backgroundColor: Colors.transparent,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           //never do this : downloadFile( widget.video.audioDownloadOptions![index], widget.video), directly cuz it will call the function before its built
                    //           onPressed: isDownloading
                    //               ? null
                    //               : () => downloadFile(
                    //                   widget.video.audioDownloadOptions![index],
                    //                   widget.video),

                    //           icon: Icon(
                    //             Icons.download,
                    //           ),
                    //         )
                    //       : null,
                    // );
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
    //TODO: see if you can minimize this setState here.
    setState(() {
      progress = null;
      progressString = null;
    });

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

    int totalSizeInBytes = stream.size.totalBytes;

    List<int> downloadedBytes = [];

    downloadStream.listen((eventBytes) {
      downloadedBytes.addAll(eventBytes);

      final downloadedLength = downloadedBytes.length;
      progress = downloadedLength.toDouble() /
          (totalSizeInBytes == 0 ? 1 : totalSizeInBytes);

      // print('eventBytes length ${eventBytes.length}');
      print('progress: ${(progress ?? 0) * 100}');

      setState(() {
        progressString = '${((progress ?? 0) * 100).toStringAsFixed(2)}%';
      });

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
        progress = null;
        progressString = '';
      });

      print('completed successfully');
    });
  }
}
