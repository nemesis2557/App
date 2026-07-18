import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'post_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      const HomeScreen(),
      PostScreen(
        onSuccess: () {
          // Switch back to Home after successfully creating a post
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      ProfileScreen(
        onEditPet: (petToEdit) {
          // Navigate to PostScreen for editing
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreen(
                petToEdit: petToEdit,
                onSuccess: () => Navigator.pop(context),
              ),
            ),
          );
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNav(
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
