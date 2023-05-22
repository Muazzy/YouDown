import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:you_down/utils/app_colors.dart';

class DialogUtils {
  static showSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.white,
              ),
        ),
      ),
    );
  }

  static showFullScreenLoading(
    BuildContext context,
    // Completer dialogContextCompleter,
  ) {
    showGeneralDialog(
      useRootNavigator:
          true, // so that i can close it using this method : Navigator.of(context, rootNavigator: true).pop() & avoid using Completer & shit

      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      // barrierColor: Colors.black45,
      barrierColor: Colors.transparent,

      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        // if (!dialogContextCompleter.isCompleted) {
        //   dialogContextCompleter.complete(context);
        // }
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(20),
              color: Colors.white.withOpacity(0),
              child: const Center(
                child: SpinKitThreeBounce(
                  color: AppColors.yellow300,
                  size: 70,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
