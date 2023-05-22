// import 'package:flutter/material.dart';
// import 'package:you_down/utils/app_colors.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// class CustomListTile extends StatelessWidget {
//   final StreamInfo stream;
//   final bool isSelected;
//   final bool isDownloaded;
//   final String progressString;
//   final bool isDownloading;
//   final VoidCallback onDownload;
//   final VoidCallback? onTap;
//   final bool isAudioTile;
//   const CustomListTile({
//     super.key,
//     required this.stream,
//     required this.isSelected,
//     required this.isDownloaded,
//     required this.progressString,
//     required this.isDownloading,
//     required this.onDownload,
//     this.isAudioTile = false,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       tileColor: Colors.white,
//       onTap: onTap,
//       leading: isAudioTile
//           ? Image.asset(
//               'assets/audio_icon.png',
//               height: 35,
//               width: 35,
//             )
//           : Image.asset(
//               'assets/video_icon.png',
//               height: 35,
//               width: 35,
//             ),
//       title: Text(
//         isAudioTile ? 'Audio' : '${stream.qualityLabel} Video',
//         style: Theme.of(context).textTheme.titleMedium!.copyWith(
//               color: AppColors.black,
//               fontWeight: FontWeight.bold,
//             ),
//       ),
//       trailing: isDownloaded
//           ? const Icon(Icons.download_done, color: AppColors.primary)
//           : Row(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Text(
//                   'Size ${stream.size.toString()}',
//                   style: const TextStyle(
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   disabledColor: Colors.grey,
//                   color: AppColors.primary,
//                   isSelected: isSelected,
//                   selectedIcon: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Transform.scale(
//                         scale: 1.3,
//                         child: const CircularProgressIndicator(
//                           color: AppColors.primary,
//                           strokeWidth: 0.5,
//                           backgroundColor: Colors.transparent,
//                         ),
//                       ),
//                       Text(
//                         progressString,
//                         textAlign: TextAlign.center,
//                         style: Theme.of(context).textTheme.labelSmall!.copyWith(
//                               color: AppColors.primary,
//                             ),
//                       ),
//                     ],
//                   ),
//                   //never do this : downloadFile( widget.video.audioDownloadOptions![index], widget.video), directly cuz it will call the function before its built
//                   onPressed: isDownloading ? null : onDownload,

//                   icon: const Icon(
//                     Icons.download,
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }


//TODO: not used  