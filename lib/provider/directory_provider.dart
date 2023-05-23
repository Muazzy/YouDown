import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/main_utils.dart';

final dirProvider =
    FutureProvider.family<String, List<bool>>((ref, bools) async {
  final isSdkAbove29 = bools[0];
  final isAudio = bools[1];

  final paths = await MainUtils.getSavedDir();

  if (paths.isEmpty) {
    return '';
  }

  final savedDir0 = Directory(paths[0]!);
  final savedDir1 = Directory(paths[1]!);
  final savedDir2 = Directory(paths[2]!);

  if (!savedDir0.existsSync()) {
    await savedDir0.create();
  }
  if (!savedDir1.existsSync()) {
    await savedDir1.create();
  }
  if (!savedDir2.existsSync()) {
    await savedDir2.create();
  }

  if (isSdkAbove29) {
    return paths[0]!;
  } else {
    return isAudio ? paths[1]! : paths[2]!;
  }
});
