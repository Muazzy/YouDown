// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_video_downloader/download_video_screen.dart';
import 'package:youtube_video_downloader/widgets/custom_textfield.dart';

import 'model/video_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String result = '';
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
            Center(
              child: Text(
                'Please paste the url of the video you want to download',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 100),
            CustomFormField(
              labelText: 'url',
              primaryColor: Colors.pink,
              textColor: Colors.black,
              textEditingController: urlCont,
              suffixIcon: IconButton(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  // var tempR = await getVideo(urlCont.text);
                  var tempR =
                      await getVideo('https://youtube.com/shorts/L3_NEXSGAQo');

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
                  Icons.download,
                ),
              ),
            ),
            SizedBox(height: 100),
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
          ],
        ),
      ),
    );
  }
}

Future<dynamic> getVideo(String url) async {
  try {
    if (url.isEmpty) {
      return 'empty url';
    }

    YoutubeExplode yt = YoutubeExplode();
    var video = await yt.videos.get(url);
    if (video.isLive) {
      yt.close(); //closing the http client so it does not interfeir with other chores and for enhanced performance

      return 'live vidoes can not be downloaded';
    } else {
      final manifest = await yt.videos.streamsClient.getManifest(url);
      // List<StreamInfo> streams = manifest.streams;

      yt.close(); //closing the http client so it does not interfeir with other chores and for enhanced performance

      return VideoModel.fromVideo(video, manifest);
    }
  } catch (e) {
    return 'Error occured while fetching the video';
  }
}
