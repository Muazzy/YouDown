import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_down/screens/home.dart';
import 'package:you_down/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
      // debug:
      //     true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouDown',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          inversePrimary: AppColors.yellow300,
        ), //for changing the action text color
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
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
      ), // useMaterial3 set to true because selectedIcon property in iconButton will not work without it.
      home: const Home(),
    );
  }
}
