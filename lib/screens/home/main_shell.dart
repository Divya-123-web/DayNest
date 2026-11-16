import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/bottom_navigation.dart';
import '../calendar/calendar_screen.dart';
import '../notes/notes_screen.dart';
import '../profile/profile_screen.dart';
import '../tasks/tasks_screen.dart';
import 'home_screen.dart';

/// The main screen after login.
/// It shows the bottom navigation bar and the currently selected tab.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Changes the selected tab.
  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // IndexedStack keeps every tab alive, so each tab remembers its state.
    final List<Widget> tabs = [
      HomeScreen(onTabChange: _changeTab),
      const TasksScreen(),
      const CalendarScreen(),
      const NotesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _changeTab,
      ),
    );
  }
}