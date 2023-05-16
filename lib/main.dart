import 'package:flutter/material.dart';
import 'package:you_down/screens/home.dart';
import 'package:you_down/utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouDown',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary.withOpacity(0.4),
          selectionHandleColor: AppColors.primary,
        ),
        appBarTheme: const AppBarTheme(
          surfaceTintColor: AppColors
              .background, // for removing the default light purple tint.
        ),
      ), // useMaterial3 set to true because selectedIcon property in iconButton will not work without it.
      home: const NewHome(),
    );
  }
}
