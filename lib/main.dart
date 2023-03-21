import 'package:flutter/material.dart';
import 'package:you_down/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light(
          useMaterial3:
              true), // useMaterial3 set to true because selectedIcon property in iconButton will not work without it.
      home: const HomeScreen(),
    );
  }
}
