import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rmss/features/admin/admin_dashboard.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/auth/views/login_screen.dart';
import 'package:rmss/features/cashier/views/desktop/cashier_dashboard.dart';
import 'package:rmss/features/cashier/views/mobile/cashier_dashboard_mobile.dart';
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
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return const CashierDashboardMobile();
                  } else {
                    return const CashierDashboard();
                  }
                },
              );
            default:
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No Role Was Assigned Yet",
                        style: TextStyle(
                          fontSize: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () =>
                            context.read<AuthBloc>().add(LogoutRequested()),
                        child: Text(
                          "Click to Logout",
                          style: TextStyle(
                            fontSize: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
          }
        }

        return const LoginScreen();
      },
    );
  }
}
