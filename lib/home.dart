// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:you_down/download_video_screen.dart';
import 'package:you_down/utils/dialog_utils.dart';
import 'package:you_down/widgets/custom_textfield.dart';

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
      backgroundColor: Colors.purple.shade50,
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
                'Paste the url of the video you want to download',
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            CustomFormField(
              labelText: 'url',
              primaryColor: Colors.purple,
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
                    ? CustomVideoWidget(video: currentVideo)
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

      final videoId = getVideoID(url);

      if (videoId.isEmpty) {
        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
        return 'Invalid url';
      }

      YoutubeExplode yt = YoutubeExplode();
      var video = await yt.videos.get(videoId);
      if (video.isLive) {
        yt.close(); //closing the http client so it does not interfeir with other chores and for enhanced performance

        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
        return 'live vidoes can not be downloaded';
      } else {
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
      print('this is the error in catch: $e');
      return 'Error occured while fetching the video,\nerror: $e';
    }
  }

  String getVideoID(String url) {
    final regex = RegExp(
        r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*');

    String? videoId = regex.firstMatch(url)?.group(1);

    return videoId ?? '';
  }
}

class CustomVideoWidget extends StatelessWidget {
  final VideoModel video;
  const CustomVideoWidget({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.all(
        Radius.circular(16),
      ),
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DownloadVideoScreen(video: video),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: video.id.toString(),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  height: 200,
                  width: double.infinity,
                  imageUrl: video.thumbnail ?? defaultThumbnail,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            PaddedText(
              textWidget: Text(
                video.title ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
                ),
              ),
            ),
            PaddedText(
                textWidget: Text(
              video.author ?? '',
              style: TextStyle(
                color: Colors.purple.shade300,
                fontStyle: FontStyle.italic,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class PaddedText extends StatelessWidget {
  final Text textWidget;
  const PaddedText({super.key, required this.textWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: textWidget,
    );
  }
}
