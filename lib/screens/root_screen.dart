import 'package:flutter/material.dart';
import 'package:zenflector/components/bottom_navigation_bar.dart';
import 'package:zenflector/screens/favorite_screen.dart';
import 'package:zenflector/screens/home_screen.dart';
import 'package:zenflector/screens/playlist_screen.dart';
import 'package:zenflector/screens/settings_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const PlaylistScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // Use IndexedStack for preserving state
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
