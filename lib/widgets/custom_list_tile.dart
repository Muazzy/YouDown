import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class CustomListTile extends StatelessWidget {
  final StreamInfo stream;
  final bool isSelected;
  final bool isDownloaded;
  final String progressString;
  final bool isDownloading;
  final VoidCallback onDownload;
  final bool isAudioTile;
  const CustomListTile({
    super.key,
    required this.stream,
    required this.isSelected,
    required this.isDownloaded,
    required this.progressString,
    required this.isDownloading,
    required this.onDownload,
    this.isAudioTile = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: isAudioTile
          ? const CircleAvatar(
              radius: 30,
              child: Icon(Icons.music_note),
            )
          : CircleAvatar(
              radius: 30,
              child: Text(
                stream.qualityLabel,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.purple.shade900,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
      title: Text(
        stream.size.toString(),
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              // color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        '${stream.codec.subtype}: ${stream.bitrate}',
      ),
      trailing: !isDownloaded
          ? IconButton(
              disabledColor: Colors.grey,
              color: Colors.purple,
              isSelected: isSelected,
              selectedIcon: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: 1.5,
                    child: const CircularProgressIndicator(
                      strokeWidth: 0.5,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Text(
                    progressString,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              //never do this : downloadFile( widget.video.audioDownloadOptions![index], widget.video), directly cuz it will call the function before its built
              onPressed: isDownloading ? null : onDownload,

              icon: const Icon(
                Icons.download,
              ),
            )
          : const Icon(Icons.download_done, color: Colors.green),
    );
  }
}
