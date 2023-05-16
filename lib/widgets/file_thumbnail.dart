import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:open_filex/open_filex.dart';
import 'package:video_player/video_player.dart';
import 'package:you_down/utils/app_colors.dart';
import 'package:you_down/widgets/common/padded_text.dart';

import '../utils/main_utils.dart';

class FileThumbnail extends StatefulWidget {
  final File file;
  const FileThumbnail(this.file, {super.key});

  @override
  State<FileThumbnail> createState() => _FileThumbnailState();
}

class _FileThumbnailState extends State<FileThumbnail> {
  //only use late when it does not need to be check that if it has initialized or not
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();

    if (MainUtils.isVideo(widget.file)) {
      controller = VideoPlayerController.file(widget.file)
        ..initialize().then((_) {
          setState(() {}); //when your thumbnail will show.
        });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileName = MainUtils.getFileName(widget.file);
    final isVideo = MainUtils.isVideo(widget.file);

    return InkWell(
      borderRadius: const BorderRadius.all(
        Radius.circular(16),
      ),
      onTap: () {
        OpenFilex.open(widget.file.path);
      },
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: getThumbnail(isVideo),
            ),
            PaddedText(
              textWidget: Text(
                fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    MainUtils.shareFile(context, widget.file);
                  },
                  icon: const Icon(
                    Icons.share,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    MainUtils.deleteFile(widget.file, context);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getThumbnail(bool isVideo) {
    Widget mediaWidget;

    if (isVideo) {
      mediaWidget = controller?.value.isInitialized == true
          ? VideoPlayer(controller!)
          : const Center(
              child: SpinKitThreeBounce(color: AppColors.primary),
            );
    } else {
      mediaWidget = const Center(
        child: Icon(
          Icons.audio_file,
          color: AppColors.primary,
          size: 200,
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: mediaWidget,
    );
  }
}
