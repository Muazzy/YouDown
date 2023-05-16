import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:you_down/utils/app_colors.dart';
import 'package:you_down/utils/main_utils.dart';
import 'package:you_down/widgets/custom_dialog.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:you_down/model/video_model.dart';
import 'package:you_down/utils/dialog_utils.dart';
import 'package:you_down/widgets/custom_list_tile.dart';

class DownloadBottomSheet extends StatefulWidget {
  final VideoModel video;
  const DownloadBottomSheet({super.key, required this.video});

  @override
  State<DownloadBottomSheet> createState() => _DownloadBottomSheetState();
}

class _DownloadBottomSheetState extends State<DownloadBottomSheet> {
  bool isPermissionGranted = false;
  String _localPath = '';
  String _videoPath = '';
  String _audioPath = '';
  String isSelected = '';
  bool isDownloading = false;
  double? progress;
  String? progressString;
  List<String> downloads = [];

  bool isDownloaded(String url) => downloads.contains(url);

  @override
  Widget build(BuildContext context) {
    List<dynamic>? allVideosAndAudio = [
      ...?widget.video.videoDownloadOptions,
      ...?widget.video.audioDownloadOptions
    ];
    return WillPopScope(
      onWillPop: () async {
        if (!isDownloading) {
          return true;
        } else {
          final bool? shouldPop = await canIPop(context);
          return shouldPop ?? false;
        }
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),

              // color: Colors.white,
              padding:
                  const EdgeInsets.only(top: 52, left: 8, right: 8, bottom: 16),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Text(
                      'Video Found',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const KDivider(),
                  ListTile(
                    leading: AspectRatio(
                      aspectRatio: 16.0 / 9.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          height: 300,
                          width: MediaQuery.of(context).size.width * 0.4,
                          imageUrl: widget.video.thumbnail ?? defaultThumbnail,
                        ),
                      ),
                    ),
                    title: Text(
                      '${widget.video.author}',
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${widget.video.title}',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const KDivider(),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // itemCount: widget.video.videoDownloadOptions!.length,
                    itemCount: allVideosAndAudio.length,
                    itemBuilder: (context, index) {
                      return CustomListTile(
                        isAudioTile: index == allVideosAndAudio.length - 1,
                        onTap: isDownloaded(
                                allVideosAndAudio[index].url.toString())
                            ? () async {
                                try {
                                  final result = await OpenFilex.open(
                                    widget.video.paths?[allVideosAndAudio[index]
                                        .url
                                        .toString()],
                                  );
                                  debugPrint(
                                      'message:${result.message}  type:${result.type}');
                                } catch (e) {
                                  DialogUtils.showSnackbar(
                                      e.toString(), context);
                                }
                              }
                            : null,
                        stream: allVideosAndAudio[index],
                        isSelected: isSelected ==
                            allVideosAndAudio[index].url.toString(),
                        isDownloaded: isDownloaded(
                          allVideosAndAudio[index].url.toString(),
                        ),
                        progressString: progressString ?? '0%',
                        isDownloading: isDownloading,
                        onDownload: () => downloadFile(
                          allVideosAndAudio[index],
                          widget.video,
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const KDivider();
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: -30,
              width: 50,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () async {
                  if (!isDownloading) {
                    Navigator.pop(context);
                  } else {
                    canIPop(context);
                  }
                },
                shape: const CircleBorder(
                  side: BorderSide(
                    color: AppColors.black,
                    width: 12,
                  ),
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
              ),
            ),
          ],
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

    debugPrint('audio path: $_audioPath');
    debugPrint('video path: $_videoPath');

    debugPrint('external path: $_localPath');
  }

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
      // final androidInfo = await deviceInfoPlugin.androidInfo;

      // Check if it's an audio or video file
      bool isAudioFile = video.audioDownloadOptions!.contains(stream);

      // Get the file extension and quality
      String extension = isAudioFile ? '.mp3' : '.mp4';
      String quality = isAudioFile ? '' : '-${stream.qualityLabel}';

      //set local path according to sdk and file type
      late final String localPath;
      if (await MainUtils.isSdkAbove29()) {
        debugPrint('local path after sdk 29 $_localPath');
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

class KDivider extends StatelessWidget {
  const KDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.textAndSecondary.withOpacity(0.1),
      thickness: 1,
      indent: 8,
      endIndent: 8,
    );
  }
}

Future<bool?> canIPop(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => customDialog(
      context,
      'Downloading',
      'Wait for the download to be completed',
    ),
  );
}
