import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:you_down/provider/downloader_provider.dart';
import 'package:you_down/provider/downloads_in_progress_provider.dart';
import 'package:you_down/utils/app_colors.dart';
import 'package:you_down/widgets/custom_dialog.dart';
import 'package:you_down/widgets/custom_download_tile.dart';
import 'package:you_down/widgets/no_downloads_widget.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(downloadProvider.notifier).initialize();
  }

  @override
  void dispose() {
    // here is the culprit which was killing the recieve port
    // and that's why when we switch bw this screen and
    // the home screen it was actually causing the port to kill so that's why weird shit was happening
    // & in simple terms the downloading tasks were not updating.

    // referenceToProvider.dispose(); //Dispose method related to flutter donwloader should not be called here.

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloadingTasks = ref.watch(downloadsInProgressProvider);
    const title = 'Downloading';
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          title,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            // vertical: 8,
          ),
          child: downloadingTasks.isNotEmpty
              ? Column(
                  children: [
                    const SizedBox(height: 16),
                    downloadingTasks.isNotEmpty
                        ? Expanded(
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                final task = downloadingTasks[index];
                                return CustomDownloadTile(
                                  task: task,
                                  onCancel: () async {
                                    bool? shouldCancel = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return confirmationDialog(
                                            context: context,
                                            title: 'Cancel?',
                                            description:
                                                'Are you sure, you want to cancel the download? ',
                                            cancelText: 'No',
                                            actionText: 'Cancel',
                                          );
                                        });

                                    if (shouldCancel != null && shouldCancel) {
                                      ref
                                          .read(downloadProvider.notifier)
                                          .cancel(task.downloadTaskId ?? '');
                                    }
                                  },
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 8);
                              },
                              itemCount: downloadingTasks.length,
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 16),
                  ],
                )
              : const NoDownloadsWidget(),
        ),
      ),
    );
  }
}
