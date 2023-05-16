import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:you_down/utils/app_colors.dart';

Widget customDialog(BuildContext context, String title, String description) {
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    elevation: 0.0,
    backgroundColor: Colors.transparent,
    child: dialogContent(context, title, description),
  );
}

Widget dialogContent(BuildContext context, String title, String description) {
  return Container(
    margin: const EdgeInsets.only(left: 0.0, right: 0.0),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              top: 8,
            ),
            margin: const EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20.0),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                      left: 10,
                      top: 0,
                      bottom: 16,
                    ),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0)),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, false);
                  },
                )
              ],
            ),
          ),
          Positioned(
            top: -15,
            width: 35,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                Navigator.pop(context, false);
              },
              shape: const CircleBorder(
                side: BorderSide(
                  color: AppColors.black,
                  width: 10,
                ),
              ),
              child: const Icon(
                Icons.close,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
