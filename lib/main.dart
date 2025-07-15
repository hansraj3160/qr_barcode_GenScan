import 'package:flutter/material.dart';
import 'pages/home_page.dart';

// Define your theme colors here
class AppColors {
  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color tileColor = Color(0xFF1E293B);
  static const Color iconColor = Color(0xFF60A5FA);
}

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.iconColor,
        scaffoldBackgroundColor:
            AppColors.backgroundColor, // Dark blue background
        cardColor: AppColors.tileColor, // Darker blue for cards/til
      ),
      home: const HomePage(),
    );
  }
}
