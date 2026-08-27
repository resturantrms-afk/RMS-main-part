import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rmss/core/theme/theme_cubit.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/kitchen/Screens/notification_screen.dart';
import 'package:rmss/features/kitchen/Screens/profile_screen.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_bloc.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_state.dart';

import '../../../core/blocs/order_bloc/order_bloc.dart';
import '../../../core/blocs/order_bloc/order_state.dart';
import '../../../core/models/order_model.dart';
import 'package:rmss/core/utils/order_utils.dart';
import '../widget/order_card.dart';
import 'order_details.dart';

class KitchenDashboard extends StatefulWidget {
  final Function(int)? onNavigate;

  const KitchenDashboard({super.key, this.onNavigate});

  @override
  State<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends State<KitchenDashboard> {
  int _activeTab = 0;

  final List<OrderStatus> _tabs = [
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.ready,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OrderError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (state is! OrderLoaded) {
          return const SizedBox();
        }

        final orders = OrderUtils.groupActiveOrdersByTable(state.items);

        final currentStatus = _tabs[_activeTab];

        final displayedOrders = orders
            .where((e) => e.status == currentStatus)
            .toList();

        final pending = orders
            .where((e) => e.status == OrderStatus.pending)
            .length;

        final preparing = orders
            .where((e) => e.status == OrderStatus.preparing)
            .length;

        final ready = orders.where((e) => e.status == OrderStatus.ready).length;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //-----------------------------------
              // HEADER
              //-----------------------------------
              Row(
                children: [
                  const Spacer(),
                  BlocBuilder<AppNotificationBloc, AppNotificationState>(
                    builder: (context, state) {
                      int unread = 0;
                      if (state is AppNotificationLoaded) {
                        unread = state.notifications
                            .where((n) => !n.isRead)
                            .length;
                      }
                      return Badge(
                        isLabelVisible: unread > 0,
                        label: Text(
                          '$unread',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (widget.onNavigate != null) {
                              widget.onNavigate!(3);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.notifications_outlined),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, state) {
                      if (state == ThemeMode.dark) {
                        return IconButton(
                          onPressed: () =>
                              context.read<ThemeCubit>().toggleTheme(),
                          icon: const Icon(Icons.light_mode_outlined),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        );
                      } else {
                        return IconButton(
                          onPressed: () =>
                              context.read<ThemeCubit>().toggleTheme(),
                          icon: const Icon(Icons.dark_mode_outlined),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      Widget avatar = CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      );
                      if (state is AuthSuccess) {
                        String urlImage = state.user.photoUrl;
                        avatar = CircleAvatar(
                          radius: 18,
                          backgroundImage: urlImage.isNotEmpty
                              ? CachedNetworkImageProvider(urlImage)
                              : null,
                          child: urlImage.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                )
                              : null,
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          if (widget.onNavigate != null) {
                            widget.onNavigate!(2);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          }
                        },
                        child: avatar,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 35),

              //-----------------------------------
              // FILTERS
              //-----------------------------------
              Row(
                children: [
                  _buildTab(context, "Pending", pending, 0),
                  const SizedBox(width: 12),
                  _buildTab(context, "Preparing", preparing, 1),
                  const SizedBox(width: 12),
                  _buildTab(context, "Ready", ready, 2),
                ],
              ),

              const SizedBox(height: 25),

              //-----------------------------------
              // GRID
              //-----------------------------------
              Expanded(
                child: displayedOrders.isEmpty
                    ? Center(
                        child: Text(
                          "No Orders",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : GridView.builder(
                        itemCount: displayedOrders.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: .8,
                            ),
                        itemBuilder: (_, index) {
                          final order = displayedOrders[index];

                          return OrderCard(
                            order: order,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailsScreen(order: order),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(BuildContext context, String title, int count, int index) {
    final active = _activeTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: active
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.15)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: active
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
