import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:youtube_video_downloader/model/video_model.dart';

class DownloadVideoScreen extends StatefulWidget {
  final VideoModel video;
  const DownloadVideoScreen({super.key, required this.video});

  @override
  State<DownloadVideoScreen> createState() => _DownloadVideoScreenState();
}

class _DownloadVideoScreenState extends State<DownloadVideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: widget.video.id.toString(),
                child: Center(
                  child: CachedNetworkImage(
                      imageUrl: widget.video.thumbnail ?? defaultThumbnail),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Video Format',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.video.videoDownloadOptions!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      child: Text(
                        widget.video.videoDownloadOptions![index].qualityLabel,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    title: Text(
                      widget.video.videoDownloadOptions![index].size.toString(),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      '${widget.video.videoDownloadOptions![index].codec.subtype}: ${widget.video.videoDownloadOptions![index].bitrate}',
                    ),
                    trailing: IconButton(
                      onPressed: () {
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
                child: Text(
                  'Audio Format',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.video.audioDownloadOptions!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      radius: 24,
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
                      widget.video.audioDownloadOptions![index].size.toString(),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
    );
  }
}
