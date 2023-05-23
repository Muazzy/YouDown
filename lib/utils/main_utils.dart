import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MainUtils {
  static Future<List<String?>> getSavedDir() async {
    if (await MainUtils.checkStoragePermission() == false) {
      return [];
    }
    const String appName = '/YouDown';

    String? externalStorageDirPath;
    String? musicDirPath;
    String? videoDirPath;

    if (Platform.isAndroid) {
      try {
        DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

        final androidInfo = await deviceInfoPlugin.androidInfo;
        if (androidInfo.version.sdkInt > 29) {
          final dir = await getExternalStorageDirectory();

          externalStorageDirPath = dir?.path;
        } else {
          externalStorageDirPath = await AndroidPathProvider.downloadsPath;
        }
        musicDirPath = await AndroidPathProvider.musicPath;
        videoDirPath = await AndroidPathProvider.moviesPath;
      } catch (err, st) {
        debugPrint('failed to get downloads path: $err, $st');

        final dir = await getApplicationDocumentsDirectory();

        externalStorageDirPath = dir.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }

    return [
      "$externalStorageDirPath$appName",
      "$musicDirPath$appName",
      "$videoDirPath$appName"
    ];
  }

  static Future<bool> checkStoragePermission() async {
    if (Platform.isIOS) {
      return true;
    }

    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

      final androidInfo = await deviceInfoPlugin.androidInfo;
      debugPrint("sdk int: ${androidInfo.version.sdkInt}");

      if (androidInfo.version.sdkInt > 29) {
        final externalStorageStatus =
            await Permission.manageExternalStorage.status;

        if (externalStorageStatus == PermissionStatus.granted) {
          return true;
        } else {
          final externalStorageResult =
              await Permission.manageExternalStorage.request();

          return externalStorageResult == PermissionStatus.granted;
        }
      } else {
        final storageStatus = await Permission.storage.status;

        if (storageStatus == PermissionStatus.granted) {
          return true;
        } else {
          final storageResult = await Permission.storage.request();
          return storageResult == PermissionStatus.granted;
        }
      }
    }

    throw StateError('unknown platform');
  }

  static requestPermission() async {
    if (await Permission.storage.isPermanentlyDenied ||
        await Permission.storage.isRestricted) {
      return 'Storage permission permanently deniend, please go to app settings & allow it manually';
    } else if (await Permission.storage.isDenied) {
      Permission.storage.request();
    } else {
      return;
    }
  }

  static Future<bool> isSdkAbove29() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    final androidInfo = await deviceInfoPlugin.androidInfo;

    return androidInfo.version.sdkInt > 29;
  }

  // static String getFileExtension(File file) {
  //   final String fileName = file.path.split('/').last;

  //   final String extension = fileName.split('.').last;

  //   return extension;
  // }

  static bool isVideo(File file) {
    final String extension = file.path.split('.').last;

    if (extension == 'mp4') {
      return true;
    } else {
      return false;
    }
  }

  static String getFileName(File file) => file.path.split('/').last;

  static String getVideoID(String url) {
    final regex = RegExp(
        r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*');

    String? videoId = regex.firstMatch(url)?.group(1);

    return videoId ?? '';
  }
}
