import 'dart:async';
import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:you_down/model/video_model.dart';
import 'package:you_down/screens/download_bottom_sheet.dart';
import 'package:you_down/utils/app_colors.dart';
import 'package:you_down/utils/dialog_utils.dart';
import 'package:you_down/utils/main_utils.dart';
import 'package:you_down/widgets/custom_textfield.dart';
import 'package:you_down/widgets/file_thumbnail.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final urlCont = TextEditingController();
  VideoModel currentVideo = VideoModel(
    thumbnail: defaultThumbnail + defaultThumbnail,
  );

  String result = '';

  List<File> _files = [];
  bool isLoadingFiles = true;
  final String appName = '/YouDown';
  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    // Request external storage permission
    if (await MainUtils.checkStoragePermission()) {
      // Get the directory to list files from
      final externalStorageDir = await getExternalStorageDirectory();
      // List files in the directory

      try {
        if (await MainUtils.isSdkAbove29()) {
          final appDir = Directory("${externalStorageDir!.path}$appName");

          final files =
              await appDir.list().where((file) => file is File).toList();
          setState(() {
            isLoadingFiles = false;
            _files = files.cast<File>();
          });
        } else {
          final musicDirPath = await AndroidPathProvider.musicPath;
          final videoDirPath = await AndroidPathProvider.moviesPath;

          final appMusicDir = Directory(musicDirPath + appName);
          final appVideoDir = Directory(videoDirPath + appName);

          final musicfiles =
              await appMusicDir.list().where((file) => file is File).toList();

          final videofiles =
              await appVideoDir.list().where((file) => file is File).toList();

          final allFiles = musicfiles + videofiles;

          setState(() {
            _files = allFiles.cast<File>();
            isLoadingFiles = false;
          });
        }
      } catch (e) {
        setState(() {
          isLoadingFiles = false;
        });
        debugPrint(e.toString());

        if (context.mounted) {
          DialogUtils.showSnackbar(e.toString(), context);
        }
      }
    }
  }

  Future<dynamic> getVideo(String url) async {
    //for dialog context (so that we can handle its state and navigation)
    final dialogContextCompleter = Completer<BuildContext>();
    DialogUtils.showFullScreenLoading(context, dialogContextCompleter);

    // Close progress dialog
    BuildContext dialogContext =
        context; //a little workaround, if i do not initialize it with some context then the when complete thing won't work.

    dialogContext = await dialogContextCompleter.future;

    try {
      if (url.isEmpty) {
        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
        return 'empty url';
      }

      final videoId = MainUtils.getVideoID(url);

      if (videoId.isEmpty) {
        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
        return 'Invalid url';
      }

      YoutubeExplode yt = YoutubeExplode();
      var video = await yt.videos.get(videoId);
      if (video.isLive) {
        print('its live video');
        yt.close(); //closing the http client so it does not interfeir with other chores and for enhanced performance

        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
        return 'live vidoes can not be downloaded';
      } else {
        print('its not a live video');

        final manifest = await yt.videos.streamsClient.getManifest(videoId);

        yt.close(); //closing the http client so it does not interfeir with other chores and for enhanced performance

        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
        return VideoModel.fromVideo(video, manifest);
      }
    } catch (e) {
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      debugPrint('this is the error in catch: $e');
      return 'Error occured while fetching the video,\nerror: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text(
            'YouDown',
            style: TextStyle(
              letterSpacing: 2,
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomFormField(
                    prefixIcon: Transform.rotate(
                      angle: 90,
                      child: const Icon(
                        Icons.link,
                        color: AppColors.black,
                        size: 28,
                      ),
                    ),
                    labelText: 'Paste link here..',
                    primaryColor: AppColors.primary,
                    textColor: AppColors.black,
                    textEditingController: urlCont,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    // var tempR = await getVideo(urlCont.text);
                    var tempR = await getVideo(urlCont.text.trim());

                    if (tempR is String) {
                      setState(() {
                        result = tempR;
                        //jugaaru way inorder to identify empty/null VideoModel instance
                        currentVideo = VideoModel(
                          thumbnail: defaultThumbnail + defaultThumbnail,
                        );
                      });
                      if (context.mounted) {
                        DialogUtils.showSnackbar(result, context);
                      }
                    } else {
                      setState(() {
                        result = '';
                        currentVideo = tempR;
                      });

                      //TODO: maybe remove this delay in production
                      Future.delayed(
                        const Duration(milliseconds: 200),
                        () {
                          if (context.mounted) {
                            showModalBottomSheet(
                              enableDrag:
                                  false, // disables the user to close the bottom sheet by dragging it down
                              isDismissible: false,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,

                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(30),
                                ),
                              ),
                              context: context,
                              builder: (context) {
                                return DownloadBottomSheet(video: currentVideo);
                              },
                            );
                          }
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: AppColors.primary, // <-- Button color
                      foregroundColor: Colors.amber.shade400 // <-- Splash color
                      ),
                  child: const Icon(
                    Icons.download_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Visibility(
              visible: _files.isNotEmpty,
              child: const Text(
                'Downloads',
                style: TextStyle(
                  color: AppColors.black,
                  // fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            isLoadingFiles
                ? Expanded(
                    child: Center(
                      child: SpinKitThreeBounce(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                  )
                : _files.isNotEmpty
                    ? Expanded(
                        child: ListView.separated(
                          itemCount: _files.length,
                          itemBuilder: (context, index) {
                            // final isVideo = MainUtils.isVideo(_files[index]);
                            return FileThumbnail(_files[index]);
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 20),
                        ),
                      )
                    : Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.grey.shade300,
                              ),
                              child: const Icon(
                                Icons.file_download_off,
                                color: AppColors.grey,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Downloads',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
