import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/features/cashier/views/desktop/home%20widgets/cashier_top_bar.dart';
import 'package:rmss/features/cashier/views/desktop/pages/order_details.dart';

class Orders extends StatefulWidget {
  Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final List<String> _selectedStatuses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, orderState) {
            if (orderState is OrderLoaded) {
              int numberOfPending = orderState.items
                  .where((item) => item.status == OrderStatus.pending)
                  .length;

              int numberOfPreparing = orderState.items
                  .where((item) => item.status == OrderStatus.preparing)
                  .length;

              int numberOfReady = orderState.items
                  .where((item) => item.status == OrderStatus.ready)
                  .length;

              int numberOfServed = orderState.items
                  .where((item) => item.status == OrderStatus.served)
                  .length;

              int numberOfCancelled = orderState.items
                  .where((item) => item.status == OrderStatus.cancelled)
                  .length;

              List<OrderModel> filteredItems = _selectedStatuses.isEmpty
                  ? orderState.items.toList()
                  : orderState.items
                        .where(
                          (item) => _selectedStatuses.contains(
                            item.status.name.toUpperCase(),
                          ),
                        )
                        .toList();

              filteredItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CashierTopBar(),

                  Text(
                    "Orders",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          _filterTile(
                            context: context,
                            isSelected: _selectedStatuses.contains(
                              OrderStatus.pending.name.toUpperCase(),
                            ),
                            numberOf: numberOfPending,
                            filterName: OrderStatus.pending.name.toUpperCase(),
                          ),
                          const SizedBox(width: 12),
                          _filterTile(
                            context: context,
                            isSelected: _selectedStatuses.contains(
                              OrderStatus.preparing.name.toUpperCase(),
                            ),
                            numberOf: numberOfPreparing,
                            filterName: OrderStatus.preparing.name
                                .toUpperCase(),
                          ),
                          const SizedBox(width: 12),
                          _filterTile(
                            context: context,
                            isSelected: _selectedStatuses.contains(
                              OrderStatus.ready.name.toUpperCase(),
                            ),
                            numberOf: numberOfReady,
                            filterName: OrderStatus.ready.name.toUpperCase(),
                          ),
                          const SizedBox(width: 12),
                          _filterTile(
                            context: context,
                            isSelected: _selectedStatuses.contains(
                              OrderStatus.served.name.toUpperCase(),
                            ),
                            numberOf: numberOfServed,
                            filterName: OrderStatus.served.name.toUpperCase(),
                          ),
                          const SizedBox(width: 12),
                          _filterTile(
                            context: context,
                            isSelected: _selectedStatuses.contains(
                              OrderStatus.cancelled.name.toUpperCase(),
                            ),
                            numberOf: numberOfCancelled,
                            filterName: OrderStatus.cancelled.name
                                .toUpperCase(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Expanded(
                    child: Center(
                      child: filteredItems.isEmpty
                          ? const Text(
                              "No orders found",
                              style: TextStyle(
                                fontSize: 20,

                                letterSpacing: 1.5,
                              ),
                            )
                          : ListView.separated(
                              itemBuilder: (context, index) {
                                final order = filteredItems[index];
                                Color statusColor = Theme.of(
                                  context,
                                ).colorScheme.primary;

                                if (order.status == OrderStatus.ready ||
                                    order.status == OrderStatus.cancelled ||
                                    order.status == OrderStatus.paid) {
                                  statusColor = Theme.of(
                                    context,
                                  ).colorScheme.outline;
                                }
                                return Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 56,
                                            width: 56,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                            ),
                                            child: Icon(
                                              Icons.table_restaurant,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ),

                                          const SizedBox(width: 16),

                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Table ${order.tableNumber}",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.restaurant,
                                                    size: 15,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "${order.items.length} Items",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: statusColor,
                                              border: Border.all(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.outlineVariant,
                                              ),
                                            ),

                                            child: Text(
                                              order.status.name.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.schedule,
                                                size: 16,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Last Edited: ${order.timeAgo()}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "TOTAL",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "\$${order.totalPrice.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w900,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 32),
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHigh,
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderDetails(
                                                          orderId: order.id,
                                                        ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.chevron_right,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, int index) =>
                                  const SizedBox(height: 24),
                              itemCount: _selectedStatuses.isEmpty
                                  ? filteredItems.length
                                  : filteredItems.length,
                            ),
                    ),
                  ),
                ],
              );
            } else if (orderState is OrderLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Loading Live Orders...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            } else if (orderState is OrderError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Error Fetching Orders",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      orderState.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _filterTile({
    required BuildContext context,
    required bool isSelected,
    required int numberOf,
    required String filterName,
  }) {
    return GestureDetector(
      onTap: () {
        if (_selectedStatuses.contains(filterName)) {
          setState(() {
            _selectedStatuses.remove(filterName);
          });
        } else {
          setState(() {
            _selectedStatuses.add(filterName);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filterName,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 8),

            numberOf > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "$numberOf",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
