import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/waiter/views/mobile/pages/orders_page.dart';
import 'package:rmss/features/waiter/views/mobile/pages/waiter_tables_grid_page.dart';
import 'package:rmss/features/waiter/views/mobile/pages/waiter_settings_page.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_bloc.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_state.dart';
import 'package:rmss/features/kitchen/Screens/notification_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rmss/core/blocs/app_branding_cubit/app_branding_cubit.dart';
import 'package:rmss/core/models/app_branding_model.dart';

class WaiterDashboardMobile extends StatefulWidget {
  const WaiterDashboardMobile({super.key});

  @override
  State<WaiterDashboardMobile> createState() => _WaiterDashboardMobileState();
}

class _WaiterDashboardMobileState extends State<WaiterDashboardMobile> {
  int _selectedIndex = 0;
  final Set<String> _shownNotifications = {};

  final List<Widget> _pages = [
    const OrdersPage(),
    const WaiterTablesGridPage(),
    const WaiterSettingsPage(),
    const WaiterSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AppNotificationBloc, AppNotificationState>(
      listener: (context, state) {
        if (state is AppNotificationLoaded) {
          // Remove IDs that are no longer unread or no longer exist
          _shownNotifications.removeWhere((id) {
            final existsAsUnread = state.notifications.any(
              (n) => n.id == id && !n.isRead,
            );
            return !existsAsUnread;
          });

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
                        icon: Icon(
                          Icons.open_in_new,
                          color: colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.primary,
                ),
              );
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainer,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopAppBar(colorScheme, textTheme),
              Expanded(
                child: IndexedStack(index: _selectedIndex, children: _pages),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(colorScheme, textTheme),
      ),
    );
  }

  Widget _buildTopAppBar(ColorScheme colorScheme, TextTheme textTheme) {
    return BlocBuilder<AppBrandingCubit, AppBrandingModel>(
      builder: (context, branding) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                state.user.photoUrl,
                              ),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            if (branding.appLogoUrl.isNotEmpty) ...[
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      branding.appLogoUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              branding.appName.isNotEmpty
                                  ? branding.appName
                                  : 'Crown Restaurant',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colorScheme.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child:
                          BlocBuilder<
                            AppNotificationBloc,
                            AppNotificationState
                          >(
                            builder: (context, notifState) {
                              int unread = 0;
                              if (notifState is AppNotificationLoaded) {
                                unread = notifState.notifications
                                    .where((n) => !n.isRead)
                                    .length;
                              }
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.notifications,
                                      color: colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const NotificationsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  if (unread > 0)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: colorScheme.error,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          '$unread',
                                          style: TextStyle(
                                            color: colorScheme.onError,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                    ),
                  ],
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        );
      },
    );
  }

  Widget _buildBottomNavBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.restaurant,
              label: "ORDERS",
              index: 0,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            _buildNavItem(
              icon: Icons.point_of_sale,
              label: "POS",
              index: 1,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            _buildNavItem(
              icon: Icons.settings,
              label: "SETTINGS",
              index: 2,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            _buildNavItem(
              icon: Icons.logout,
              label: "LOGOUT",
              index: 3,
              colorScheme: colorScheme,
              textTheme: textTheme,
              onTap: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap:
          onTap ??
          () {
            setState(() {
              _selectedIndex = index;
            });
          },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 10,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
