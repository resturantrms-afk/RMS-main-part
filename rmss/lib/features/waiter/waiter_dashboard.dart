import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';

class WaiterDashboard extends StatelessWidget {
  const WaiterDashboard({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Waiter Dashboard")),
      body: Center(
        child: GestureDetector(
          onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
          child: Text(
            "Click to Logout",
            style: TextStyle(
              fontSize: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
