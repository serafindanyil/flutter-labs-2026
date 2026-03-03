import 'package:first_lab/pages/home/home_page.dart';
import 'package:first_lab/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
