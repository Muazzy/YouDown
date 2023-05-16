import 'package:flutter/material.dart';

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
