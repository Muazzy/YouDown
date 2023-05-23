import 'package:flutter/material.dart';
import 'package:you_down/utils/app_colors.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class CustomCheckboxListTile extends StatelessWidget {
  final StreamInfo stream;
  final bool isSelected;

  final void Function(bool?) onChanged;
  final bool isAudioTile;
  const CustomCheckboxListTile({
    super.key,
    required this.stream,
    required this.isSelected,
    this.isAudioTile = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      onChanged: onChanged,
      value: isSelected,
      secondary: isAudioTile
          ? Image.asset(
              'assets/audio_icon.png',
              height: 35,
              width: 35,
            )
          : Image.asset(
              'assets/video_icon.png',
              height: 35,
              width: 35,
            ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isAudioTile ? 'Audio' : '${stream.qualityLabel} Video',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          Text(
            'Size ${stream.size.toString()}',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
      activeColor: AppColors.primary,
    );
  }
}
