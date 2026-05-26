import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const ScienceStudioOS());
}

class ScienceStudioOS extends StatelessWidget {
  const ScienceStudioOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Science Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF060608),
        primaryColor: Colors.deepPurpleAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.cyanAccent,
          surface: Color(0xFF0F0F14),
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

