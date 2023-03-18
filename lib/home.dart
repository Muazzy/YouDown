// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_video_downloader/download_video_screen.dart';
import 'package:youtube_video_downloader/utils/dialog_utils.dart';
import 'package:youtube_video_downloader/widgets/custom_textfield.dart';

import 'model/video_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String result = '';
  bool isLoading = false;
  final urlCont = TextEditingController();
  VideoModel currentVideo = VideoModel(
    thumbnail: defaultThumbnail + defaultThumbnail,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Center(
              child: Text(
                'Please paste the url of the video you want to download',
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            CustomFormField(
              labelText: 'url',
              primaryColor: Colors.pink,
              textColor: Colors.black,
              textEditingController: urlCont,
              suffixIcon: IconButton(
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
                  } else {
                    setState(() {
                      result = '';
                      currentVideo = tempR;
                    });
                  }
                },
                icon: Icon(
                  Icons.search,
                ),
              ),
            ),
            Spacer(),
            result.isNotEmpty
                ? Text(result)
                : currentVideo.thumbnail != defaultThumbnail + defaultThumbnail
                    ? ListTile(
                        leading: Hero(
                          tag: currentVideo.id.toString(),
                          child: CachedNetworkImage(
                            imageUrl:
                                currentVideo.thumbnail ?? defaultThumbnail,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        title: Text(currentVideo.title ?? ''),
                        subtitle: Text(currentVideo.author ?? ''),
                        trailing: Text(currentVideo.duration ?? ''),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DownloadVideoScreen(video: currentVideo),
                            ),
                          );
                        },
                      )
                    : SizedBox.shrink(),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Future<dynamic> getVideo(String url) async {
    //for dialog context (so that we can handle its state and navigation)
    final dialogContextCompleter = Completer<BuildContext>();
    DialogUtils.showFullScreenLoading(context, dialogContextCompleter);

    // setState(() {
    //   isLoading = true;
    // });

    // Close progress dialog
    BuildContext dialogContext =
        context; //a little workaround, if i do not initialize it with some context then the when complete thing won't work.

    dialogContext = await dialogContextCompleter.future;

    try {
      if (url.isEmpty) {
        // setState(() {
        //   isLoading = false;

        // });

        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
        return 'empty url';
      }

      final videoId = getVideoID(url);

      if (videoId.isEmpty) {
        // setState(() {
        //   isLoading = false;
        // });
        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
        return 'Invalid url';
      }

      YoutubeExplode yt = YoutubeExplode();
      var video = await yt.videos.get(videoId);
      if (video.isLive) {
        yt.close(); //closing the http client so it does not interfeir with other chores and for enhanced performance
        // setState(() {
        //   isLoading = false;
        // });
        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
        return 'live vidoes can not be downloaded';
      } else {
        final manifest = await yt.videos.streamsClient.getManifest(url);
        // List<StreamInfo> streams = manifest.streams;

        yt.close(); //closing the http client so it does not interfeir with other chores and for enhanced performance
        // setState(() {
        //   isLoading = false;
        // });
        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
        return VideoModel.fromVideo(video, manifest);
      }
    } catch (e) {
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      return 'Error occured while fetching the video';
    }
  }

  String getVideoID(String url) {
    final regex = RegExp(
        r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*');

    String? videoId = regex.firstMatch(url)?.group(1);

    return videoId ?? '';
  }
}