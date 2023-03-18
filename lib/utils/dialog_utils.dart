import 'dart:async';

import 'package:flutter/material.dart';

class DialogUtils {
  static showFullScreenLoading(
      BuildContext context, Completer<BuildContext> dialogContextCompleter) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        if (!dialogContextCompleter.isCompleted) {
          dialogContextCompleter.complete(context);
        }
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(20),
            color: Colors.white.withOpacity(0),
            child: const Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
    );
  }
}