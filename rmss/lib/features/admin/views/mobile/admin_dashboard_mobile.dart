import 'package:flutter/material.dart';

class AdminDashboardMobile extends StatefulWidget {
  const AdminDashboardMobile({super.key});

  @override
  State<AdminDashboardMobile> createState() => _AdminDashboardMobileState();
}

class _AdminDashboardMobileState extends State<AdminDashboardMobile> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Screen Size too small Desktop Only")),
    );
  }
}
