import 'dart:io';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:you_down/model/video_model.dart';
import 'package:you_down/utils/dialog_utils.dart';
import 'package:you_down/widgets/custom_list_tile.dart';

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
    return WillPopScope(
      onWillPop: () async {
        if (!isDownloading) {
          return true;
        } else {
          final bool? shouldPop = await showDialog<bool>(
              context: context,
              builder: (conext) => AlertDialog(
                    backgroundColor: Colors.purple.shade900,
                    title: Text(
                      'Downloading',
                      style: TextStyle(color: Colors.purple.shade50),
                    ),
                    content: Text(
                      'Wait for the download to be completed',
                      style: TextStyle(color: Colors.purple.shade50),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text(
                          'Ok',
                          style: TextStyle(color: Colors.purple.shade50),
                        ),
                      ),
                    ],
                  ));
          return shouldPop ?? false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.purple.shade50,
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
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.purple.shade900,
                            ),
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.video.videoDownloadOptions!.length,
                    itemBuilder: (context, index) {
                      return CustomListTile(
                        onTap: isDownloaded(widget
                                .video.videoDownloadOptions![index].url
                                .toString())
                            ? () async {
                                try {
                                  final result = await OpenFilex.open(
                                    widget.video.paths?[widget
                                        .video.videoDownloadOptions?[index].url
                                        .toString()],
                                  );
                                  print(
                                      'message:${result.message}  type:${result.type}');
                                } catch (e) {
                                  DialogUtils.showSnackbar(
                                      e.toString(), context);
                                }
                              }
                            : null,
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
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.purple.shade900,
                            ),
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.video.audioDownloadOptions!.length,
                    itemBuilder: (context, index) {
                      return CustomListTile(
                        onTap: isDownloaded(widget
                                .video.audioDownloadOptions![index].url
                                .toString())
                            ? () async {
                                try {
                                  final result = await OpenFilex.open(
                                    widget.video.paths?[widget
                                        .video.audioDownloadOptions?[index].url
                                        .toString()],
                                  );
                                  print(
                                      'message:${result.message}  type:${result.type}');
                                } catch (e) {
                                  DialogUtils.showSnackbar(
                                      e.toString(), context);
                                }
                              }
                            : null,
                        isAudioTile: true,
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
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: Colors.purple.shade100,
                        thickness: 1,
                      );
                    },
                  ),
                ],
              ),
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
    return '$externalStorageDirPath/you_down';
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
      if (context.mounted) {
        DialogUtils.showSnackbar('permission not granted', context);
      }
      return;
    }

    await _prepareSaveDir();
    setState(() {});

    bool isAudioFile = video.audioDownloadOptions!
        .contains(stream); //for checking if its a an audio stream/file

    String extension = isAudioFile ? '.mp3' : '.mp4';
    String quality = isAudioFile ? '' : '-${stream.qualityLabel}';

    YoutubeExplode yt = YoutubeExplode();

    var downloadStream = yt.videos.streamsClient.get(stream);

    var file = File('$_localPath/${video.title}$quality$extension');
    if (file.existsSync()) {
      int i = 1;
      while (file.existsSync()) {
        file = File('$_localPath/${video.title}$quality-$i$extension');
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

      setState(() {
        progressString = '${((progress ?? 0) * 100).toStringAsFixed(2)}%';
      });

      fileStream.add(eventBytes);
    }).onDone(() async {
      DialogUtils.showSnackbar('File Downloaded: ${file.path}', context);
      await fileStream.flush();
      await fileStream.close();
      print('before ${video.paths}');
      setState(() {
        video.paths?.addAll({stream.url.toString(): file.path});
        downloads
            .add(stream.url.toString()); //change this to the path of the file
        print('after ${video.paths}');

        isDownloading = false;
        isSelected = '';
        progress = null;
        progressString = '';
      });
    });
  }
}
