import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:you_down/model/download_task_model.dart';
import 'package:you_down/model/video_model.dart';
import 'package:you_down/utils/app_colors.dart';

class CustomDownloadTile extends StatelessWidget {
  final DownloadTaskModel task;
  final Function() onCancel;

  const CustomDownloadTile(
      {super.key, required this.task, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final String title = task.isAudio ? 'Audio' : 'Video';
    return Card(
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.hardEdge,
            children: [
              ListTile(
                minVerticalPadding: 16,
                leading: AspectRatio(
                  aspectRatio: 16.0 / 9.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      height: 300,
                      width: MediaQuery.of(context).size.width * 0.4,
                      imageUrl: task.imgUrl ?? defaultThumbnail,
                    ),
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  task.fileName,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: task.progress! / 100,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          InkWell(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            onTap: onCancel,
            child: Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0)),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}
