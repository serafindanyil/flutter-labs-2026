import 'package:first_lab/pages/main/main_page.dart';
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
      title: 'SmartRecu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MainPage(),
    );
  }
}
