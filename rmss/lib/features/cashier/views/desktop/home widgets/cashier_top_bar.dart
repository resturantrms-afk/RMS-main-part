import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_bloc.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_event.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_state.dart';
import 'package:rmss/core/models/app_notification_model.dart';
import 'package:rmss/core/theme/theme_cubit.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/kitchen/Screens/notification_screen.dart';

class CashierTopBar extends StatelessWidget {
  const CashierTopBar({super.key});

  void _showNotificationsPanel(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, state) {
            if (state == ThemeMode.dark) {
              return IconButton(
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                icon: const Icon(Icons.light_mode_outlined),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              );
            } else {
              return IconButton(
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                icon: const Icon(Icons.dark_mode_outlined),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              );
            }
          },
        ),
        const SizedBox(width: 8),
        BlocBuilder<AppNotificationBloc, AppNotificationState>(
          builder: (context, state) {
            int unread = 0;
            if (state is AppNotificationLoaded) {
              unread = state.notifications.where((n) => !n.isRead).length;
            }
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => _showNotificationsPanel(context),
                  icon: const Icon(Icons.notifications_outlined),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                if (unread > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          color: Colors.white,
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
        const SizedBox(width: 16),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              String urlImage = state.user.photoUrl;
              return CircleAvatar(
                radius: 18,
                backgroundImage: CachedNetworkImageProvider(urlImage),
              );
            }
            return CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            );
          },
        ),
      ],
    );
  }
}
