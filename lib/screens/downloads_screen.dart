import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:you_down/provider/downloader_provider.dart';
import 'package:you_down/provider/downloads_in_progress_provider.dart';
import 'package:you_down/utils/app_colors.dart';
import 'package:you_down/widgets/custom_download_tile.dart';
import 'package:you_down/widgets/no_downloads_widget.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  late dynamic something;
  @override
  void initState() {
    super.initState();
    ref.read(downloadProvider.notifier).initialize();
  }

  @override
  void dispose() {
    // _myDispose();
    something.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    something = ref.read(downloadProvider.notifier);
    super.didChangeDependencies();
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
                                  onCancel: () {
                                    ref
                                        .read(downloadProvider.notifier)
                                        .cancel(task.downloadTaskId ?? '');
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
