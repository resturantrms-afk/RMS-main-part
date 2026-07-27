import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/admin/views/desktop/admin_dashboard.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_bloc.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_event.dart';

import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/auth/views/login_screen.dart';
import 'package:rmss/features/cashier/views/desktop/cashier_dashboard.dart';

import 'package:rmss/features/kitchen/Screens/kitchen_main_layout.dart';

import 'package:rmss/features/waiter/views/mobile/waiter_dashboard_mobile.dart';

class RoleRouterScreen extends StatelessWidget {
  const RoleRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Only fires when auth state actually changes — safe place for side effects
        if (state is AuthSuccess) {
          // Reset first to wipe any previous session's data, then start fresh
          context.read<AppNotificationBloc>().add(const ResetNotifications());
          context.read<AppNotificationBloc>().add(
            StartListeningToNotifications(role: state.user.role),
          );
        } else if (state is AuthUnauthenticated) {
          // Clear notifications the moment the user logs out
          context.read<AppNotificationBloc>().add(const ResetNotifications());
        }
      },
      builder: (context, state) {
        if (state is AuthSuccess) {
          final String userRole = state.user.role.name;
          switch (userRole) {
            case "admin":
              return const AdminDashboard();
            case "waiter":
              return const WaiterDashboardMobile();
            case "kitchen":
              return const KitchenMainLayout();
            case "cashier":
              return const CashierDashboard();

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
