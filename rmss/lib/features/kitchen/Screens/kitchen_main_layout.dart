import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_bloc.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_state.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';
import 'package:rmss/features/kitchen/Screens/kitchen_dashboard.dart';
import 'package:rmss/features/kitchen/Screens/availability_screen.dart';
import 'package:rmss/features/kitchen/Screens/notification_screen.dart';
import 'package:rmss/features/kitchen/Screens/profile_screen.dart';
import 'package:rmss/core/blocs/app_branding_cubit/app_branding_cubit.dart';
import 'package:rmss/core/models/app_branding_model.dart';

class KitchenMainLayout extends StatefulWidget {
  const KitchenMainLayout({super.key});

  @override
  State<KitchenMainLayout> createState() => _KitchenMainLayoutState();
}

class _KitchenMainLayoutState extends State<KitchenMainLayout> {
  // Tracks which page is currently active on the right side
  int _currentIndex = 0;
  bool isExpanded = true;
  final Set<String> _shownNotifications = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
        return NotificationsScreen(
          onBack: () => setState(() => _currentIndex = 0),
        );
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
    return BlocListener<AppNotificationBloc, AppNotificationState>(
      listener: (context, state) {
        if (state is AppNotificationLoaded) {
          for (var notification in state.notifications) {
            if (!notification.isRead &&
                !_shownNotifications.contains(notification.id)) {
              _shownNotifications.add(notification.id);

              if (notification.playSound) {
                final player = AudioPlayer();
                player.setVolume(notification.volume / 100.0);
                player.play(AssetSource('sounds/beep.mp3'));
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              notification.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(notification.message),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.open_in_new,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          setState(() => _currentIndex = 3);
                        },
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
          }
        }
      },
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
                          ? BlocBuilder<AppBrandingCubit, AppBrandingModel>(
                              builder: (context, branding) {
                                return SizedBox(
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
                                          image: branding.appLogoUrl.isNotEmpty
                                              ? DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                        branding.appLogoUrl,
                                                      ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: branding.appLogoUrl.isEmpty
                                            ? Icon(
                                                Icons.restaurant,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              branding.appName.isNotEmpty
                                                  ? branding.appName
                                                  : 'Crown Restaurant',
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                fontSize: 16,
                                                letterSpacing: 1.2,
                                                fontWeight: FontWeight.w800,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                                );
                              },
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
      ), // closes Scaffold
    ); // closes BlocListener
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
