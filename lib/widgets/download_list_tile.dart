// import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:you_down/model/download_task_model.dart';
// import 'package:you_down/utils/app_colors.dart';

// class DownloadListItem extends StatelessWidget {
//   const DownloadListItem({
//     super.key,
//     required this.taskModel,
//     required this.onCancel,
//     required this.onResume,
//     required this.onPause,
//     required this.onRetry,
//   });

//   final DownloadTaskModel taskModel;
//   final Function() onCancel;
//   final Function() onResume;
//   final Function() onPause;
//   final Function() onRetry;

//   Widget? _buildTrailing(DownloadTaskModel task) {
//     if (task.downloadStatus == DownloadTaskStatus.running) {
//       return Row(
//         children: [
//           Text('${task.progress}%'),
//           IconButton(
//             onPressed: onPause,
//             constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
//             icon: const Icon(Icons.pause, color: AppColors.primary),
//             tooltip: 'Pause',
//           ),
//         ],
//       );
//     } else if (task.downloadStatus == DownloadTaskStatus.paused) {
//       return Row(
//         children: [
//           Text('${task.progress}%'),
//           IconButton(
//             onPressed: onResume,
//             constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
//             icon: const Icon(Icons.play_arrow, color: AppColors.primary),
//             tooltip: 'Resume',
//           ),
//           IconButton(
//             onPressed: onCancel,
//             constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
//             icon: const Icon(Icons.cancel, color: AppColors.yellow300),
//             tooltip: 'Cancel',
//           ),
//         ],
//       );
//     } else if (task.downloadStatus == DownloadTaskStatus.failed) {
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           const Text(
//             'Failed',
//             style: TextStyle(color: Colors.red),
//           ),
//           IconButton(
//             onPressed: onRetry,
//             constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
//             icon: const Icon(Icons.refresh, color: AppColors.primary),
//             tooltip: 'Refresh',
//           )
//         ],
//       );
//     } else {
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // print(taskModel.downloadStatus);
//     return Container(
//       padding: const EdgeInsets.only(left: 16, right: 8),
//       child: InkWell(
//         child: Stack(
//           children: [
//             SizedBox(
//               width: double.infinity,
//               height: 64,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       taskModel.fileName,
//                       maxLines: 1,
//                       softWrap: true,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8),
//                     child: _buildTrailing(taskModel),
//                   ),
//                 ],
//               ),
//             ),
//             if (taskModel.downloadStatus == DownloadTaskStatus.running ||
//                 taskModel.downloadStatus == DownloadTaskStatus.paused)
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: LinearProgressIndicator(
//                   value: taskModel.progress! / 100,
//                   color: AppColors.primary,
//                 ),
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }


//TODO: not used anymore