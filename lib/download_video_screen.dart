import 'dart:io';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:you_down/utils/main_utils.dart';
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
  String _localPath = '';
  String _videoPath = '';
  String _audioPath = '';
  String isSelected = '';
  bool isDownloading = false;
  double? progress;
  String? progressString;
  List<String> downloads = [];
  final String appName = 'YouDown';

  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

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
    // _localPath = (await _getSavedDir())!;
    final paths = await MainUtils.getSavedDir();
    _localPath = paths[0]!;
    _audioPath = paths[1]!;
    _videoPath = paths[2]!;
    final savedDir0 = Directory(_localPath);
    final savedDir1 = Directory(_audioPath);
    final savedDir2 = Directory(_videoPath);

    if (!savedDir0.existsSync()) {
      await savedDir0.create();
    }
    if (!savedDir1.existsSync()) {
      await savedDir1.create();
    }
    if (!savedDir2.existsSync()) {
      await savedDir2.create();
    }

    print('audio path: $_audioPath');
    print('video path: $_videoPath');

    print('external path: $_localPath');
  }

  // Future<List<String?>> _getSavedDir() async {
  //   String? externalStorageDirPath;
  //   String? musicDirPath;
  //   String? videoDirPath;

  //   if (Platform.isAndroid) {
  //     try {
  //       final androidInfo = await deviceInfoPlugin.androidInfo;
  //       if (androidInfo.version.sdkInt > 29) {
  //         final directories = await getExternalStorageDirectories();

  //         print(directories);
  //         final dir = await getExternalStorageDirectory();

  //         externalStorageDirPath = dir?.path;
  //       } else {
  //         externalStorageDirPath = await AndroidPathProvider.downloadsPath;
  //       }
  //       musicDirPath = await AndroidPathProvider.musicPath;
  //       videoDirPath = await AndroidPathProvider.moviesPath;
  //     } catch (err, st) {
  //       print('failed to get downloads path: $err, $st');

  //       final dir = await getApplicationDocumentsDirectory();

  //       externalStorageDirPath = dir.path;
  //     }
  //   } else if (Platform.isIOS) {
  //     externalStorageDirPath =
  //         (await getApplicationDocumentsDirectory()).absolute.path;
  //   }

  //   return [
  //     "$externalStorageDirPath/$appName",
  //     "$musicDirPath/$appName",
  //     "$videoDirPath/$appName"
  //   ];
  // }

  // Future<bool> _checkPermission() async {
  //   if (Platform.isIOS) {
  //     return true;
  //   }

  //   if (Platform.isAndroid) {
  //     final androidInfo = await deviceInfoPlugin.androidInfo;
  //     print("sdk int: ${androidInfo.version.sdkInt}");

  //     if (androidInfo.version.sdkInt > 29) {
  //       final externalStorageStatus =
  //           await Permission.manageExternalStorage.status;

  //       if (externalStorageStatus == PermissionStatus.granted) {
  //         return true;
  //       } else {
  //         final externalStorageResult =
  //             await Permission.manageExternalStorage.request();

  //         return externalStorageResult == PermissionStatus.granted;
  //       }
  //     } else {
  //       final storageStatus = await Permission.storage.status;

  //       if (storageStatus == PermissionStatus.granted) {
  //         return true;
  //       } else {
  //         final storageResult = await Permission.storage.request();
  //         return storageResult == PermissionStatus.granted;
  //       }
  //     }
  //   }

  //   throw StateError('unknown platform');
  // }

  //TODO: move this to controller file if state management created.
  Future<void> downloadFile(StreamInfo stream, VideoModel video) async {
    try {
      // Clear previous progress and set downloading state
      setState(() {
        progress = null;
        progressString = null;
        isDownloading = true;
        isSelected = stream.url.toString();
      });

      // Check if permission is granted
      isPermissionGranted = await MainUtils.checkStoragePermission();
      setState(() {});

      if (!isPermissionGranted) {
        setState(() {
          isDownloading = false;
          isSelected = '';
        });
        if (context.mounted) {
          DialogUtils.showSnackbar('Permission not granted', context);
        }
        return;
      }

      // Prepare the directory for saving the file
      await _prepareSaveDir();
      setState(() {});

      //for getting the android sdk info.
      final androidInfo = await deviceInfoPlugin.androidInfo;

      // Check if it's an audio or video file
      bool isAudioFile = video.audioDownloadOptions!.contains(stream);

      // Get the file extension and quality
      String extension = isAudioFile ? '.mp3' : '.mp4';
      String quality = isAudioFile ? '' : '-${stream.qualityLabel}';

      //set local path according to sdk and file type
      late final String localPath;
      if (androidInfo.version.sdkInt > 29) {
        print('local path after sdk 29 $_localPath');
        localPath = _localPath;
      } else {
        localPath = isAudioFile ? _audioPath : _videoPath;
      }

      try {
        // Create an instance of the YoutubeExplode client
        YoutubeExplode yt = YoutubeExplode();

        // Get the stream for the given video
        var downloadStream = yt.videos.streamsClient.get(stream);

        // Create the file to save the downloaded stream
        var file = File('$localPath/${video.title}$quality$extension');

        //handling the issue of duplicate file
        if (file.existsSync()) {
          int i = 1;
          while (file.existsSync()) {
            file = File('$localPath/${video.title}$quality-$i$extension');
            i++;
          }
        }

        // Open a write stream to the file
        var fileStream = file.openWrite(mode: FileMode.write);

        // Get the total size of the stream
        int totalSizeInBytes = stream.size.totalBytes;

        // List to keep track of downloaded bytes
        List<int> downloadedBytes = [];

        // Listen to the stream and write to the file
        downloadStream.listen((eventBytes) {
          downloadedBytes.addAll(eventBytes);

          final downloadedLength = downloadedBytes.length;
          progress = downloadedLength.toDouble() /
              (totalSizeInBytes == 0 ? 1 : totalSizeInBytes);

          setState(() {
            progressString = '${((progress ?? 0) * 100).toStringAsFixed(1)}%';
          });

          fileStream.add(eventBytes);
        }).onDone(() async {
          // Close the file stream
          await fileStream.flush();
          await fileStream.close();

          // Update the paths and downloads
          setState(() {
            video.paths?.addAll({stream.url.toString(): file.path});
            downloads.add(stream.url.toString());

            // Reset the state
            isDownloading = false;
            isSelected = '';
            progress = null;
            progressString = '';

            // Show the snackbar with the downloaded file path
            DialogUtils.showSnackbar('File Downloaded: ${file.path}', context);
          });
        });
      } catch (e) {
        // Handle any errors during the download process
        if (context.mounted) {
          DialogUtils.showSnackbar(
              'An error occurred: ${e.toString()}', context);
        }
        setState(() {
          isDownloading = false;
          isSelected = '';
          progress = null;
          progressString = '';
        });
      }
    } catch (e) {
      // Handle any errors during the download process
      if (context.mounted) {
        DialogUtils.showSnackbar('An error occurred: ${e.toString()}', context);
      }
      setState(() {
        isDownloading = false;
        isSelected = '';
        progress = null;
        progressString = '';
      });
    }
  }

  //end
}
