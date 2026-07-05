import 'package:flutter/material.dart';

class CashierDashboardMobile extends StatefulWidget {
  const CashierDashboardMobile({super.key});

  @override
  State<CashierDashboardMobile> createState() => _CashierDashboardMobileState();
}

class _CashierDashboardMobileState extends State<CashierDashboardMobile> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Screen Size too small Desktop Only")),
    );
  }
}
