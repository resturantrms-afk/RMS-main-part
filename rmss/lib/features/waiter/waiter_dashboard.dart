import 'package:flutter/material.dart';

class WaiterDashboard extends StatelessWidget {
  const WaiterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Waiter Dashboard")),
      body: const Center(child: Text("Waiter View")),
    );
  }
}
