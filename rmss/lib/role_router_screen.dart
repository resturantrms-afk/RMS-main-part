import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/admin/admin_dashboard.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/cashier/views/desktop/cashier_dashboard.dart';
import 'package:rmss/features/kitchen/Screens/kitchen_dashboard.dart';

import 'package:rmss/features/waiter/waiter_dashboard.dart';

class RoleRouterScreen extends StatelessWidget {
  const RoleRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // We will hook this up to Firebase later, but let's mock it for now

        if (state is AuthSuccess) {
          final String userRole = state.user.role.name;
          switch (userRole) {
            case "admin":
              return const AdminDashboard();
            case "waiter":
              return const WaiterDashboard();
            case "kitchen":
              return const KitchenDashboard();
            case "cashier":
              return const CashierDashboard();
            default:
              return const Scaffold(body: CashierDashboard());
          }
        }

        return const Scaffold(body: Center(child: Text("No Role Assigned")));
      },
    );
  }
}
