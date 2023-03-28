import 'dart:io';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:you_down/utils/dialog_utils.dart';
import 'package:you_down/utils/main_utils.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({super.key});

  @override
  FileListPageState createState() => FileListPageState();
}

class FileListPageState extends State<FileListPage> {
  List<File> _files = [];
  bool isLoading = true;
  final String appName = '/YouDown';
  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    // Request external storage permission
    if (await MainUtils.checkStoragePermission()) {
      // Get the directory to list files from
      final externalStorageDir = await getExternalStorageDirectory();
      // List files in the directory

      try {
        if (await MainUtils.isSdkAbove29()) {
          final appDir = Directory("${externalStorageDir!.path}$appName");

          final files =
              await appDir.list().where((file) => file is File).toList();
          setState(() {
            _files = files.cast<File>();
          });
        } else {
          final musicDirPath = await AndroidPathProvider.musicPath;
          final videoDirPath = await AndroidPathProvider.moviesPath;

          final appMusicDir = Directory(musicDirPath + appName);
          final appVideoDir = Directory(videoDirPath + appName);

          final musicfiles =
              await appMusicDir.list().where((file) => file is File).toList();

          final videofiles =
              await appVideoDir.list().where((file) => file is File).toList();

          final allFiles = musicfiles + videofiles;

          setState(() {
            _files = allFiles.cast<File>();
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        debugPrint(e.toString());

        if (context.mounted) {
          DialogUtils.showSnackbar(e.toString(), context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isNotEmpty
              ? ListView.separated(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final fileName = MainUtils.getFileName(_files[index]);
                    final fileIcon = MainUtils.getFileIcon(_files[index]);
                    return ListTile(
                      onTap: () {
                        OpenFilex.open(_files[index].path);
                      },
                      leading: Icon(
                        fileIcon,
                        color: Colors.purple.shade500,
                      ),
                      title: Text(
                        fileName,
                        style: TextStyle(
                          color: Colors.purple.shade900,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.purple.shade50,
                  ),
                )
              : const Center(
                  child: Text('No Downloads'),
                ),
    );
  }
}
