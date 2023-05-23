import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:you_down/model/video_model.dart';
import 'package:you_down/provider/downloader_provider.dart';
import 'package:you_down/provider/downloads_in_progress_provider.dart';
import 'package:you_down/provider/files_provider.dart';
import 'package:you_down/provider/video_provider.dart';
import 'package:you_down/screens/download_bottom_sheet.dart';
import 'package:you_down/screens/downloads_screen.dart';
import 'package:you_down/utils/app_colors.dart';
import 'package:you_down/utils/dialog_utils.dart';
import 'package:you_down/utils/main_utils.dart';
import 'package:you_down/widgets/custom_badge.dart';
import 'package:you_down/widgets/custom_dialog.dart';
import 'package:you_down/widgets/custom_textfield.dart';
import 'package:you_down/widgets/file_thumbnail.dart';
import 'package:you_down/widgets/no_downloads_widget.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  late dynamic
      referenceToProvider; //cuz i can't figure out the type of that shit bruh

  late TextEditingController urlCont;

  @override
  void initState() {
    super.initState();
    urlCont = TextEditingController();
    //calling this shit here too so the tasks get updated even when the user is not on downloading tasks screen
    ref
        .read(downloadProvider.notifier)
        .initialize(); //will setup all the port, isolates and shit to update the download tasks in UI.
  }

  @override
  void dispose() {
    super.dispose();
    urlCont.dispose();
    referenceToProvider.dispose();
  }

  @override
  void didChangeDependencies() {
    referenceToProvider = ref.read(downloadProvider.notifier);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    Rect? sharePositionRect = (box?.localToGlobal(Offset.zero) ?? Offset.zero) &
        (box?.size ?? Size.zero);

    //files provider
    final files = ref.watch(fileProvider);
    final fileToggler = ref.read(fileProvider.notifier);

    //video provider
    ref.listen(videoProvider, (prev, next) {
      next.when(
        data: (data) {
          DialogUtils(context).stopLoading();
          if (data is VideoModel) {
            return Future.delayed(
              const Duration(milliseconds: 200),
              () {
                if (context.mounted) {
                  showModalBottomSheet(
                    useRootNavigator: false,
                    enableDrag:
                        false, // disables the user to close the bottom sheet by dragging it down
                    isDismissible: false,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,

                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    context: context,
                    builder: (context) {
                      return DownloadBottomSheet(video: data);
                    },
                  );
                }
              },
            );
          } else {
            DialogUtils(context).showSnackbar(data.toString());
          }
        },
        error: (e, s) {
          DialogUtils(context)
              .stopLoading(); //first stop loading then show the snackbar
          DialogUtils(context).showSnackbar(e.toString());
        },
        loading: () {
          DialogUtils(context).showFullScreenLoading();
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const TitleWidget(),
        actions: [
          DownloadsIcon(ref: ref),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await fileToggler.refreshFiles();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: Transform.rotate(
                        angle: 90,
                        child: const Icon(
                          Icons.link,
                          color: AppColors.black,
                          size: 28,
                        ),
                      ),
                      labelText: 'Paste link here..',
                      primaryColor: AppColors.primary,
                      textColor: AppColors.black,
                      textEditingController: urlCont,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      if (await MainUtils.checkStoragePermission()) {
                        ref.read(videoProvider.notifier).getVideo(
                              urlCont.text.trim(),
                            );
                      } else {
                        if (context.mounted) {
                          DialogUtils(context).showSnackbar(
                            'permission not allowed',
                            // context,
                            SnackBarAction(
                              label: 'Allow here',
                              onPressed: () async {
                                // print('hello im clicked');
                                final String? error =
                                    await MainUtils.requestPermission();

                                if (error?.isNotEmpty ?? false) {
                                  if (context.mounted) {
                                    DialogUtils(context).showSnackbar(
                                      error.toString(),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.primary, // <-- Button color
                        foregroundColor:
                            Colors.amber.shade400 // <-- Splash color
                        ),
                    child: const Icon(
                      Icons.download_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Visibility(
                visible: files.value?.isNotEmpty ?? false,
                child: const Text(
                  'Downloads',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 24,
                  ),
                ),
              ),
              files.when(data: (data) {
                if (data.isEmpty) {
                  return const Expanded(child: NoDownloadsWidget());
                }
                return Expanded(
                  child: ListView.separated(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return FileThumbnail(
                        data[index],
                        onTap: () {
                          fileToggler.openFile(data[index]);
                        },
                        onShare: () {
                          fileToggler.shareFile(
                            data[index],
                            sharePositionRect,
                          );
                        },
                        onDelete: () async {
                          bool? shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return confirmationDialog(
                                  context: context,
                                  title: 'Delete',
                                  description:
                                      'Are you sure, you want to delete it? ',
                                  cancelText: 'Cancel',
                                  actionText: 'Delete',
                                );
                              });

                          if (shouldDelete != null && shouldDelete) {
                            fileToggler.deleteFile(data[index]);
                          }
                        },
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                  ),
                );
              }, error: (e, s) {
                return Expanded(
                    child: Center(
                  child: Text(e.toString()),
                ));
              }, loading: () {
                return Expanded(
                  child: Center(
                    child: SpinKitThreeBounce(
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class DownloadsIcon extends StatelessWidget {
  const DownloadsIcon({
    super.key,
    required this.ref,
  });

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return CustomBadge(
      showBadge: ref.watch(downloadsInProgressProvider).isNotEmpty,
      badgeContent: ref.watch(downloadsInProgressProvider).length.toString(),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return const DownloadsScreen();
            }),
          );
        },
        icon: const Icon(
          Icons.download_outlined,
          size: 30,
        ),
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Text(
        'YouDown',
        style: TextStyle(
          letterSpacing: 2,
          fontSize: 18,
        ),
      ),
    );
  }
}
