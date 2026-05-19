import 'package:flutter/material.dart';

class KitchenDashboard extends StatelessWidget {
  const KitchenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kitchen Dashboard")),
      body: const Center(child: Text("Kitchen View")),
    );
  }
}
