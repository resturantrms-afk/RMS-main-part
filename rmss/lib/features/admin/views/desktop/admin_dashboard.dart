import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';
import 'package:rmss/features/admin/blocs/navigation_cubit/navigation.state.dart';
import 'package:rmss/features/admin/blocs/navigation_cubit/navigation_cubit.dart';
import 'package:rmss/features/admin/views/desktop/pages/admin_home.dart';
import 'package:rmss/features/admin/views/desktop/pages/menu.dart';
import 'package:rmss/features/admin/views/desktop/pages/orders.dart';
import 'package:rmss/features/admin/views/desktop/pages/payments.dart';
import 'package:rmss/features/admin/views/desktop/pages/settings.dart';
import 'package:rmss/features/admin/blocs/notification_bloc/admin_notification_bloc.dart';
import 'package:rmss/features/admin/blocs/notification_bloc/admin_notification_state.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_ai.dart';
import 'package:rmss/features/admin/views/desktop/pages/users.dart';
import 'package:rmss/features/admin/views/desktop/pages/tables.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState) {
        final pages = [
          const AdminHome(),
          Menu(preSelectedTable: navState.preSelectedTable),
          Orders(),
          const Payments(),
          const TablesPage(),
          const UsersPage(),
          const ReportsAiPage(),
          const Settings(),
        ];
        return BlocListener<AdminNotificationBloc, AdminNotificationState>(
          listener: (context, state) {
            if (state is AdminNotificationShow) {
              if (state.notification.playSound) {
                final player = AudioPlayer();
                player.setVolume(state.notification.volume / 100.0);
                player.play(
                  UrlSource(
                    'https://actions.google.com/sounds/v1/alarms/beep_short.ogg',
                  ),
                );
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.notification.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(state.notification.message),
                    ],
                  ),
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
          },
          child: Scaffold(
            body: Stack(
              children: [
                Row(
                  children: [
                    NavigationRail(
                      minExtendedWidth: 220,
                      minWidth: 65,

                      unselectedLabelTextStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                      selectedLabelTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),

                      unselectedIconTheme: IconThemeData(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 28,
                      ),

                      selectedIconTheme: IconThemeData(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      // waxa loo isticmaalaa marka option la select gareeyo waxa soo baxaya
                      indicatorColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.25),
                      // obvious
                      indicatorShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),

                      // obvious
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          isExpanded
                              ? SizedBox(
                                  width: 260,
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainer,
                                          shape: BoxShape.circle,
                                        ),

                                        child: Icon(
                                          Icons.restaurant,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Crown Restaurant",
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                fontSize: 16,
                                                letterSpacing: 1.2,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),

                                            Text(
                                              "Admin",
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(height: 16),
                        ],
                      ),

                      onDestinationSelected: (index) =>
                          context.read<NavigationCubit>().navigateTo(index),
                      selectedIndex: navState.selectedIndex,
                      destinations: [
                        _buildDestination(
                          label: "Dashboard",
                          icon: Icons.dashboard,
                        ),
                        _buildDestination(
                          label: "Menu & POS",
                          icon: Icons.restaurant_menu,
                        ),
                        _buildDestination(
                          label: "Orders",
                          icon: Icons.shopping_cart,
                        ),
                        _buildDestination(
                          label: "payments",
                          icon: Icons.payment,
                        ),
                        _buildDestination(
                          label: "Tables",
                          icon: Icons.table_restaurant,
                        ),
                        _buildDestination(label: "Users", icon: Icons.people),
                        _buildDestination(
                          label: "Reports & AI",
                          icon: Icons.stacked_line_chart,
                        ),
                        _buildDestination(
                          label: "Setting",
                          icon: Icons.settings,
                        ),
                      ],

                      extended: isExpanded,
                    ),

                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: pages[navState.selectedIndex],
                        ),
                      ),
                    ),
                  ],
                ),

                // expanding and contracting the navigation rail
                Positioned(
                  top: 16,
                  left: 12,
                  child: IconButton(
                    onPressed: () => setState(() {
                      isExpanded = !isExpanded;
                    }),
                    icon: const Icon(Icons.menu),
                  ),
                ),

                Positioned(
                  bottom: 32,
                  left: 20.5,

                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () =>
                          context.read<AuthBloc>().add(LogoutRequested()),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          isExpanded
                              ? Text(
                                  "Sign out",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  NavigationRailDestination _buildDestination({
    required String label,
    required IconData icon,
  }) {
    return NavigationRailDestination(
      padding: const EdgeInsets.symmetric(vertical: 2),
      icon: Icon(icon, size: isExpanded ? 28 : 24),
      label: Text(label),
      selectedIcon: Icon(icon, size: isExpanded ? 30 : 26),
    );
  }
}
