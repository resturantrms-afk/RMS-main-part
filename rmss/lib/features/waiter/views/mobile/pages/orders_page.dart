import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_event.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_event.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/core/models/roles/waiter_model.dart';
import 'package:rmss/core/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/utils/order_utils.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _selectedTab = 0; // 0 for Ready Orders, 1 for Cleaning

  @override
  void initState() {
    super.initState();
    // Assuming the bloc is already loading orders globally, if not we dispatch LoadOrder
    // context.read<OrderBloc>().add(LoadOrder());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Segmented Control / Tabs
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    title: "Ready Orders",
                    isSelected: _selectedTab == 0,
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    title: "Cleaning",
                    isSelected: _selectedTab == 1,
                    onTap: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Title
          Builder(
            builder: (context) {
              int pendingCount = 0;
              if (_selectedTab == 0) {
                final state = context.watch<OrderBloc>().state;
                if (state is OrderLoaded) {
                  pendingCount = state.items
                      .where((o) => o.status == OrderStatus.ready)
                      .length;
                }
              } else {
                final state = context.watch<TableBloc>().state;
                if (state is TablesLoaded) {
                  pendingCount = state.items
                      .where((t) => t.status == TableStatus.needsCleaning)
                      .length;
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _selectedTab == 0
                          ? "Priority Service"
                          : "Cleaning Service",
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "$pendingCount PENDING",
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Orders / Tables List
          Expanded(
            child: Builder(
              builder: (context) {
                if (_selectedTab == 0) {
                  final state = context.watch<OrderBloc>().state;
                  if (state is OrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrderError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is OrderLoaded) {
                    final readyOrdersRaw = state.items
                        .where((order) => order.status == OrderStatus.ready)
                        .toList();
                    final readyOrders = OrderUtils.groupActiveOrdersByTable(readyOrdersRaw);

                    if (readyOrders.isEmpty) {
                      return Center(
                        child: Text(
                          "No ready orders",
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(
                        bottom: 100,
                      ), // Space for bottom nav
                      itemCount: readyOrders.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final order = readyOrders[index];
                        return _buildOrderCard(
                          order,
                          colorScheme,
                          textTheme,
                          context,
                        );
                      },
                    );
                  }
                  return const SizedBox();
                } else {
                  final state = context.watch<TableBloc>().state;
                  if (state is TablesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TableError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is TablesLoaded) {
                    final dirtyTables = state.items
                        .where(
                          (table) => table.status == TableStatus.needsCleaning,
                        )
                        .toList();

                    if (dirtyTables.isEmpty) {
                      return Center(
                        child: Text(
                          "No cleaning tasks",
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(
                        bottom: 100,
                      ), // Space for bottom nav
                      itemCount: dirtyTables.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final table = dirtyTables[index];
                        return _buildTableCard(
                          table,
                          colorScheme,
                          textTheme,
                          context,
                        );
                      },
                    );
                  }
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    OrderModel order,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Table ${order.tableNumber.toString().padLeft(2, '0')}",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.timeAgo(),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              final orderState = context.read<OrderBloc>().state;
              if (orderState is OrderLoaded) {
                final orderIds = order.id.split(',');
                final originalOrders = orderState.items.where((o) => orderIds.contains(o.id)).toList();

                for (var origOrder in originalOrders) {
                  if (origOrder.status == OrderStatus.ready) {
                    context.read<OrderBloc>().add(
                      UpdateOrder(
                        item: origOrder.copyWith(
                          status: OrderStatus.served,
                          updatedAt: Timestamp.now(),
                        ),
                      ),
                    );

                    // Log the 'served' action for each original order
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthSuccess) {
                      final action = WaiterAction(
                        tableId: origOrder.tableId,
                        actionType: WaiterActionType.served,
                        date: Timestamp.now(),
                        orderId: origOrder.id,
                      );
                      context.read<UserRepository>().logWaiterAction(
                        authState.user.id,
                        action,
                      );
                    }
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              elevation: 4,
              shadowColor: colorScheme.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              "SERVED",
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(
    TableModel table,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Table ${table.tableNumber.toString().padLeft(2, '0')}",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.cleaning_services,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Needs Cleaning",
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TableBloc>().add(
                UpdateTable(
                  item: TableModel(
                    id: table.id,
                    tableNumber: table.tableNumber,
                    status: TableStatus.available,
                  ),
                ),
              );

              // Log the 'cleaned' action
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthSuccess) {
                final action = WaiterAction(
                  tableId: table.id,
                  actionType: WaiterActionType.cleaned,
                  date: Timestamp.now(),
                );
                context.read<UserRepository>().logWaiterAction(
                  authState.user.id,
                  action,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              elevation: 4,
              shadowColor: colorScheme.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              "CLEANED",
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
