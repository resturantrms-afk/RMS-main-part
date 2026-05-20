import 'package:flutter/material.dart';

class WaiterDashboard extends StatelessWidget {
  const WaiterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiter Dashboard'),
      ),
      body: const WaiterDashboardBody(),
    );
  }
}

class WaiterDashboardBody extends StatelessWidget {
  const WaiterDashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Welcome to the Waiter Dashboard',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}