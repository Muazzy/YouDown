import 'package:flutter/material.dart';
import 'package:you_down/utils/app_colors.dart';

class PaddedText extends StatelessWidget {
  final Text textWidget;
  const PaddedText({super.key, required this.textWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: textWidget,
    );
  }
}

class KDivider extends StatelessWidget {
  const KDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.textAndSecondary.withOpacity(0.1),
      thickness: 1,
      indent: 8,
      endIndent: 8,
    );
  }
}
