import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_event.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/core/utils/order_utils.dart';
import 'package:rmss/features/waiter/views/mobile/pages/waiter_menu_page.dart';

class WaiterHistoryPage extends StatelessWidget {
  final String orderId;
  final TableModel table;
  const WaiterHistoryPage({
    super.key,
    required this.orderId,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, orderState) {
        if (orderState is OrderLoaded) {
          final orderIds = orderId.split(',');
          final originalOrders = orderState.items
              .where((o) => orderIds.contains(o.id))
              .toList();
          if (originalOrders.isEmpty)
            return const Center(child: Text("Order not found"));
          final order = OrderUtils.mergeOrders(originalOrders);
          double totalTax = order.totalTax;
          double subtotal = order.totalPrice - totalTax;
          return BlocBuilder<MenuBloc, MenuState>(
            builder: (context, menuState) {
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                appBar: AppBar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.8),
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text(
                    "Table Order History",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  centerTitle: true,
                ),
                body: order.items.isEmpty
                    ? Center(
                        child: Text(
                          "No items in this order.",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Total Amount
                                const Text(
                                  "TOTAL AMOUNT",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "SUBTOTAL: \$${subtotal.toStringAsFixed(2)}  |  TAX: \$${totalTax.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "\$${order.totalPrice.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 48),
                                // Items List
                                ...originalOrders.map((origOrder) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (originalOrders.length > 1)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: Text(
                                            "Part - ${origOrder.status.name.toUpperCase()}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ...origOrder.items.map((item) {
                                        String? imageUrl;
                                        if (menuState is MenuLoaded) {
                                          final menuItem = menuState.items
                                              .where(
                                                (m) => m.id == item.menuItemId,
                                              )
                                              .firstOrNull;
                                          imageUrl = menuItem?.imageUrl;
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.surfaceContainer,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .shadow
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Image
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: SizedBox(
                                                    width: 80,
                                                    height: 80,
                                                    child:
                                                        imageUrl != null &&
                                                            imageUrl.isNotEmpty
                                                        ? CachedNetworkImage(
                                                            imageUrl: imageUrl,
                                                            fit: BoxFit.cover,
                                                            placeholder:
                                                                (
                                                                  _,
                                                                  _,
                                                                ) => Container(
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).colorScheme.surfaceContainerHighest,
                                                                ),
                                                            errorWidget: (_, _, _) => Container(
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .surfaceContainerHighest,
                                                              child: const Icon(
                                                                Icons
                                                                    .restaurant,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .surfaceContainerHighest,
                                                            child: const Icon(
                                                              Icons.restaurant,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                // Details
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.name,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      if (item
                                                          .notes
                                                          .isNotEmpty) ...[
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          item.notes,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).colorScheme.primary,
                                                                ),
                                                              ),
                                                              if (order.status ==
                                                                      OrderStatus
                                                                          .pending ||
                                                                  order.status ==
                                                                      OrderStatus
                                                                          .preparing)
                                                                IconButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .delete_outline,
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).colorScheme.error,
                                                                    size: 20,
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  constraints:
                                                                      const BoxConstraints(),
                                                                  onPressed: () {
                                                                    final updatedItems =
                                                                        List<
                                                                          OrderItemModel
                                                                        >.from(
                                                                          order
                                                                              .items,
                                                                        );
                                                                    updatedItems.removeWhere(
                                                                      (i) =>
                                                                          i.menuItemId ==
                                                                              item.menuItemId &&
                                                                          i.notes ==
                                                                              item.notes,
                                                                    );

                                                                    if (updatedItems
                                                                        .isEmpty) {
                                                                      final updatedOrder = order.copyWith(
                                                                        status:
                                                                            OrderStatus.cancelled,
                                                                        items:
                                                                            [],
                                                                        totalPrice:
                                                                            0.0,
                                                                        updatedAt:
                                                                            Timestamp.now(),
                                                                      );
                                                                      context
                                                                          .read<
                                                                            OrderBloc
                                                                          >()
                                                                          .add(
                                                                            UpdateOrder(
                                                                              item: updatedOrder,
                                                                            ),
                                                                          );
                                                                    } else {
                                                                      double
                                                                      newSubtotal = updatedItems.fold(
                                                                        0.0,
                                                                        (
                                                                          sum,
                                                                          i,
                                                                        ) =>
                                                                            sum +
                                                                            (i.price *
                                                                                i.quantity),
                                                                      );
                                                                      double newTax = newSubtotal * (order.taxPercent / 100);
                                                                      final updatedOrder = order.copyWith(
                                                                        items:
                                                                            updatedItems,
                                                                        totalPrice:
                                                                            newSubtotal +
                                                                            newTax,
                                                                        updatedAt:
                                                                            Timestamp.now(),
                                                                      );
                                                                      context
                                                                          .read<
                                                                            OrderBloc
                                                                          >()
                                                                          .add(
                                                                            UpdateOrder(
                                                                              item: updatedOrder,
                                                                            ),
                                                                          );
                                                                    }
                                                                  },
                                                                ),
                                                            ],
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .surfaceContainerHigh,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              "x${item.quantity}",
                                                              style: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                letterSpacing:
                                                                    1.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                bottomNavigationBar: order.items.isEmpty
                    ? null
                    : Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.9),
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WaiterMenuPage(table: table),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.4),
                          ),
                          child: const Text(
                            "ADD MORE ITEMS",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
