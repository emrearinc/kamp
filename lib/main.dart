// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/camp_list_screen.dart';

void main() {
  runApp(const CampApp());
}

class CampApp extends StatelessWidget {
  const CampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamp Checklist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D32), // kamp havası için yeşil
      ),
      home: const CampListScreen(),
    );
  }
}
