import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/waiter/views/mobile/pages/orders_page.dart';
import 'package:rmss/features/waiter/views/mobile/pages/waiter_tables_grid_page.dart';
import 'package:rmss/features/waiter/views/mobile/pages/waiter_settings_page.dart';
import 'package:rmss/features/waiter/blocs/notification_bloc/waiter_notification_bloc.dart';
import 'package:rmss/features/waiter/blocs/notification_bloc/waiter_notification_state.dart';
import 'package:audioplayers/audioplayers.dart';

class WaiterDashboardMobile extends StatefulWidget {
  const WaiterDashboardMobile({super.key});

  @override
  State<WaiterDashboardMobile> createState() => _WaiterDashboardMobileState();
}

class _WaiterDashboardMobileState extends State<WaiterDashboardMobile> {
  int _selectedIndex = 0;

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

    return BlocListener<WaiterNotificationBloc, WaiterNotificationState>(
      listener: (context, state) {
        if (state is WaiterNotificationShow) {
          if (state.notification.playSound) {
            final player = AudioPlayer();
            player.setVolume(state.notification.volume / 100.0);
            // Playing a generic beep. For offline support, add an mp3 to assets and use AssetSource('sound.mp3')
            player.play(UrlSource('https://actions.google.com/sounds/v1/alarms/beep_short.ogg'));
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
              backgroundColor: colorScheme.primary,
            ),
          );
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Crown Restaurant",
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.notifications, color: colorScheme.primary),
                    onPressed: () {
                      // TODO: Notifications logic
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
  }

  Widget _buildBottomNavBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
