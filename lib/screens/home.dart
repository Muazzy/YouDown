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
import 'package:you_down/widgets/custom_badge.dart';
import 'package:you_down/widgets/custom_textfield.dart';
import 'package:you_down/widgets/file_thumbnail.dart';
import 'package:you_down/widgets/no_downloads_widget.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final urlCont = TextEditingController();

  // final ReceivePort _port = ReceivePort();

  // have to have all this logic of isolates and init states & dispose in a provider so that i can litsen to the changes even when im on another screen

  @override
  void initState() {
    super.initState();

    ref
        .read(downloadProvider.notifier)
        .initialize(); //will setup all the port, isolates and shit to update the download tasks in UI.

    // _bindBackgroundIsolate();

    // FlutterDownloader.registerCallback(downloadCallback, step: 1);
  }

  // void _bindBackgroundIsolate() {
  //   final isSuccess = IsolateNameServer.registerPortWithName(
  //     _port.sendPort,
  //     'downloader_send_port',
  //   );
  //   if (!isSuccess) {
  //     _unbindBackgroundIsolate();
  //     _bindBackgroundIsolate();
  //     return;
  //   }
  //   _port.listen((dynamic data) {
  //     final taskId = (data as List<dynamic>)[0] as String;
  //     final status = DownloadTaskStatus(data[1] as int);
  //     final progress = data[2] as int;

  //     print(
  //       'Callback on UI isolate: '
  //       'task ($taskId) is in status ($status) and process ($progress)',
  //     );

  //     final downloadTasks = ref.watch(downloadProvider);
  //     // final downloadTasks = ref.watch(downloadProvider).value;

  //     if (downloadTasks.isNotEmpty) {
  //       ref
  //           .read(downloadProvider.notifier)
  //           .updateTask(taskId, progress, status);
  //     }
  //   });
  // }

  @override
  void dispose() {
    //TODO: try adding this initstate in both the places without the provider & see what happens
    // & also remove this initstate thingy from this class and only put it in the other downloads one, see what happenss!
    // _unbindBackgroundIsolate();

    super.dispose();
    ref.read(downloadProvider.notifier).dispose();
  }

  // void _unbindBackgroundIsolate() {
  //   IsolateNameServer.removePortNameMapping('downloader_send_port');
  // }

  // @pragma('vm:entry-point')
  // static void downloadCallback(
  //   String id,
  //   int status,
  //   int progress,
  // ) {
  //   print(
  //     'Callback on background isolate: '
  //     'task ($id) is in status ($status) and process ($progress)',
  //   );

  //   IsolateNameServer.lookupPortByName('downloader_send_port')
  //       ?.send([id, status, progress]);
  // }

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
          // Navigator.of(context, rootNavigator: true)
          //     .pop(); //close the loading dialog

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
            DialogUtils.showSnackbar(data.toString(), context);
          }
        },
        error: (e, s) {
          // Navigator.of(context, rootNavigator: true)
          //     .pop(); //close the loading dialog
          DialogUtils.showSnackbar(e.toString(), context);
        },
        loading: () {
          // DialogUtils.showFullScreenLoading(
          //   context,
          // );
          DialogUtils.showSnackbar('loading bitch', context);
        },
      );
    });

//TODO : the button's border is not clickable in the bottomsheet top
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Container(
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
        ),
        actions: [
          CustomBadge(
            showBadge: ref.watch(downloadsInProgressProvider).isNotEmpty,
            // showBadge: ref.watch(downloadProvider).value?.isNotEmpty ?? false,

            badgeContent:
                ref.watch(downloadsInProgressProvider).length.toString(),

            // badgeContent:
            //     ref.watch(downloadProvider).value?.length.toString() ?? '',
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return DownloadsScreen();
                  }),
                );
              },
              icon: const Icon(
                Icons.download_outlined,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
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

                    ref.read(videoProvider.notifier).getVideo(
                          // urlCont.text.trim(),
                          'https://youtu.be/Yj1IihCcPe0',
                        );
                  },
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: AppColors.primary, // <-- Button color
                      foregroundColor: Colors.amber.shade400 // <-- Splash color
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
                      onDelete: () {
                        fileToggler.deleteFile(data[index]);
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
    );
  }
}
