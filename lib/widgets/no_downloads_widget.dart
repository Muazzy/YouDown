import 'package:flutter/material.dart';
import 'package:you_down/utils/app_colors.dart';

class NoDownloadsWidget extends StatelessWidget {
  const NoDownloadsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey.shade300,
          ),
          child: const Icon(
            Icons.file_download_off,
            color: AppColors.grey,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'No Downloads',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.grey),
        ),
      ],
    );
  }
}
