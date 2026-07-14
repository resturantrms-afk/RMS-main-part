import 'package:flutter/material.dart';
import 'package:rmss/features/kitchen/widget/kitchen_sidebar.dart';
import 'package:rmss/features/kitchen/Screens/kitchen_dashboard.dart';
import 'package:rmss/features/kitchen/Screens/availability_screen.dart';
import 'package:rmss/features/kitchen/Screens/notification_screen.dart';
import 'package:rmss/features/kitchen/Screens/profile_screen.dart'; 

class KitchenMainLayout extends StatefulWidget {
  const KitchenMainLayout({super.key});

  @override
  State<KitchenMainLayout> createState() => _KitchenMainLayoutState();
}

class _KitchenMainLayoutState extends State<KitchenMainLayout> {
  // Tracks which page is currently active on the right side
  int _currentIndex = 0;

  // List of all the screens from your design
  final List<Widget> _screens = [
    const KitchenDashboard(), // Index 0: Orders Dashboard
    const AvailabilityScreen(), // Index 1
    const NotificationsScreen(), // Index 2
    const ProfileScreen(), // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A1E17),
      body: Row(
        children: [
          // ==========================================
          // 1. THE PERSISTENT SIDEBAR
          // ==========================================
          KitchenSidebar(
            onMenuSelected: (index) {
              setState(() {
                _currentIndex = index; // Switch the active screen based on sidebar click
              });
            },
          ),

          // ==========================================
          // 2. THE DYNAMIC MAIN CONTENT AREA
          // ==========================================
          Expanded(
            child: _screens[_currentIndex], // Renders the selected screen dynamically
          ),
        ],
      ),
    );
  }
}