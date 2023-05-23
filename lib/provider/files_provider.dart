import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:you_down/utils/main_utils.dart';

class FileNotifier extends AsyncNotifier<List<File>> {
  @override
  Future<List<File>> build() async {
    return _fetchFiles();
  }

  Future<List<File>> _fetchFiles() async {
    if (await MainUtils.checkStoragePermission()) {
      const String appName = '/YouDown';

      // Get the directory to list files from
      final externalStorageDir = await getExternalStorageDirectory();
      // List files in the directory

      if (await MainUtils.isSdkAbove29()) {
        final appDir = Directory("${externalStorageDir!.path}$appName");

        if (await appDir.exists()) {
          final files =
              await appDir.list().where((file) => file is File).toList();

          return files.cast<File>();
        }
      } else {
        final musicDirPath = await AndroidPathProvider.musicPath;
        final videoDirPath = await AndroidPathProvider.moviesPath;

        final appMusicDir = Directory(musicDirPath + appName);
        final appVideoDir = Directory(videoDirPath + appName);

        if (await appMusicDir.exists() && await appVideoDir.exists()) {
          final musicfiles =
              await appMusicDir.list().where((file) => file is File).toList();

          final videofiles =
              await appVideoDir.list().where((file) => file is File).toList();

          final allFiles = musicfiles + videofiles;

          return allFiles.cast<File>();
        }
      }
      return [];
    }
    return [];
  }

  Future<void> deleteFile(File file) async {
    state = const AsyncLoading();

    if (file.existsSync()) {
      state = await AsyncValue.guard(() {
        file.deleteSync();

        return _fetchFiles();
      });
    } else {
      state = AsyncError('File does not exist', StackTrace.current);
    }
  }

  // no need to use AsyncValue.guard in share & open method as it updates the state, howeveer we do not want to update any state.
  // only throw error when the file does not exists for some reason

  Future<void> shareFile(File file, Rect? sharePositionOrigin) async {
    if (file.existsSync()) {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '',
        text: '',
        sharePositionOrigin: sharePositionOrigin,
      );
    } else {
      state = AsyncError('File does not exist', StackTrace.current);
    }
  }

  Future<void> openFile(File file) async {
    if (file.existsSync()) {
      OpenFilex.open(file.path);
    } else {
      state = AsyncError('File does not exist', StackTrace.current);
    }
  }

  Future<void> refreshFiles() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() {
      return _fetchFiles();
    });
  }
}

final fileProvider = AsyncNotifierProvider<FileNotifier, List<File>>(() {
  return FileNotifier();
});
