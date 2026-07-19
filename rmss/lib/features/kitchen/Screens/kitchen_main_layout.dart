import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';
import 'package:rmss/features/kitchen/Screens/kitchen_dashboard.dart';
import 'package:rmss/features/kitchen/Screens/availability_screen.dart';
import 'package:rmss/features/kitchen/Screens/notification_screen.dart';
import 'package:rmss/features/kitchen/services/kitchen_notification_service.dart';
import 'package:rmss/features/kitchen/Screens/profile_screen.dart';

class KitchenMainLayout extends StatefulWidget {
  const KitchenMainLayout({super.key});

  @override
  State<KitchenMainLayout> createState() => _KitchenMainLayoutState();
}

class _KitchenMainLayoutState extends State<KitchenMainLayout> {
  // Tracks which page is currently active on the right side
  int _currentIndex = 0;
  bool isExpanded = true;
  late final KitchenNotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = KitchenNotificationService();
    _notificationService.startListening();
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }

  Widget get _currentScreen {
    switch (_currentIndex) {
      case 0:
        return KitchenDashboard(
          onNavigate: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
      case 1:
        return AvailabilityScreen(
          onNavigate: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
      case 2:
        return const ProfileScreen();
      case 3:
        return const NotificationsScreen();
      default:
        return KitchenDashboard(
          onNavigate: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<KitchenNotificationService>.value(
      value: _notificationService,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
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
                  indicatorColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.25),
                  indicatorShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),

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
                                          "Kitchen",
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

                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  selectedIndex: _currentIndex > 2 ? null : _currentIndex,
                  destinations: [
                    _buildDestination(
                      label: "Orders",
                      icon: Icons.restaurant_menu,
                    ),
                    _buildDestination(
                      label: "Availability",
                      icon: Icons.calendar_today,
                    ),
                    _buildDestination(
                      label: "Profile",
                      icon: Icons.person_outline,
                    ),
                  ],

                  extended: isExpanded,
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Material(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(32),
                      clipBehavior: Clip.antiAlias,
                      child: _currentScreen,
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
              child: GestureDetector(
                onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
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
          ],
        ),
      ),
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
