import 'package:education_app/instructor/addCourse.dart';
import 'package:flutter/material.dart';

// Screens
import 'package:education_app/student/studentHomeScreen.dart';
import 'package:education_app/notifications/notificationsScreen.dart';
import 'package:education_app/coursesScreen.dart/myCoueses.dart';
import 'package:education_app/settings/settingsScreen.dart';

// Resources
import 'package:education_app/resources/colors.dart';

class InsHomeScreen extends StatefulWidget {
  final int index;

  InsHomeScreen({this.index = 0});

  @override
  _InsHomeScreenState createState() => _InsHomeScreenState();
}

class _InsHomeScreenState extends State<InsHomeScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    StudentHomeScreen(),
    NotificationScreen(),
    AddCourseScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 0),
              _buildNavItem(Icons.notifications, 1),
              _buildNavItem(Icons.book, 2),
              _buildNavItem(Icons.settings, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }
}
