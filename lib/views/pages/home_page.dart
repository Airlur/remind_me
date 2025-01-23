import 'package:flutter/material.dart';
import 'package:remind_me/views/pages/date/date_page.dart';
import 'package:remind_me/views/pages/time/time_page.dart';
import 'package:remind_me/views/pages/settings/settings_page.dart';
import 'package:remind_me/views/widgets/common/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final _pages = const [
    DatePage(),
    TimePage(), 
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}