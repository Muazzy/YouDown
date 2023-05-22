import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_down/provider/selected_downlods_provider.dart';
import 'package:you_down/utils/app_colors.dart';
import 'package:you_down/widgets/checkbox_list_tile.dart';
import 'package:you_down/widgets/common/common_widgets.dart';
import 'package:you_down/model/video_model.dart';

class DownloadBottomSheet extends ConsumerStatefulWidget {
  final VideoModel video;
  const DownloadBottomSheet({super.key, required this.video});

  @override
  ConsumerState<DownloadBottomSheet> createState() =>
      _DownloadBottomSheetState();
}

class _DownloadBottomSheetState extends ConsumerState<DownloadBottomSheet> {
  @override
  Widget build(BuildContext context) {
    List<dynamic>? allVideosAndAudio = [
      ...?widget.video.videoDownloadOptions,
      ...?widget.video.audioDownloadOptions
    ];
    return WillPopScope(
      onWillPop: () {
        ref.read(selectedDownloadsProvider.notifier).reset();
        return Future.value(true);
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
                    itemCount: allVideosAndAudio.length,
                    itemBuilder: (context, index) {
                      final currentVideo = allVideosAndAudio[index];
                      final isStreamSelected =
                          ref.watch(isSelectedProvider(currentVideo));
                      return CustomCheckboxListTile(
                        isAudioTile: index == allVideosAndAudio.length - 1,
                        stream: currentVideo,
                        isSelected: isStreamSelected,
                        onChanged: (newValue) {
                          isStreamSelected
                              ? ref
                                  .read(selectedDownloadsProvider.notifier)
                                  .unSelect(allVideosAndAudio[index])
                              : ref
                                  .read(selectedDownloadsProvider.notifier)
                                  .select(allVideosAndAudio[index]);
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const KDivider();
                    },
                  ),
                  const KDivider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: AppColors.black,
                            backgroundColor: AppColors.white,
                            side: const BorderSide(
                              color: AppColors.black,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            disabledBackgroundColor:
                                AppColors.primary.withOpacity(0.5),
                            disabledForegroundColor:
                                AppColors.white.withOpacity(0.5),
                          ),
                          onPressed: ref
                                  .watch(selectedDownloadsProvider)
                                  .isNotEmpty
                              ? () async {
                                  await ref
                                      .read(selectedDownloadsProvider.notifier)
                                      .addToDownloader(widget.video)
                                      .then((value) {
                                    //after adding those tasks, clear the selected ones.
                                    ref
                                        .read(
                                            selectedDownloadsProvider.notifier)
                                        .reset();
                                    Navigator.pop(context);
                                  });
                                }
                              : null,
                          child: const Text('Download'),
                        ),
                      ),
                    ],
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
                  ref.read(selectedDownloadsProvider.notifier).reset();
                  Navigator.pop(context);
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
}
