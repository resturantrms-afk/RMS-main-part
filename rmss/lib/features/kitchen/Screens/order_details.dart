import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/blocs/menu_bloc/menu_bloc.dart';
import '../../../core/blocs/menu_bloc/menu_state.dart';
import '../../../core/blocs/order_bloc/order_bloc.dart';
import '../../../core/blocs/order_bloc/order_event.dart';
import '../../../core/blocs/order_bloc/order_state.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Order #${order.id}",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //-----------------------------------
            // LEFT SIDE
            //-----------------------------------
            Expanded(
              flex: 2,

              child: Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER INFORMATION",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 25),

                    _infoTile(context, "Table", order.tableNumber.toString()),

                    _infoTile(context, "Source", order.source.name),

                    _infoTile(
                      context,
                      "Status",
                      order.status.name.toUpperCase(),
                    ),

                    _infoTile(
                      context,
                      "Total",
                      "\$${order.totalPrice.toStringAsFixed(2)}",
                    ),

                    const SizedBox(height: 30),

                    const Divider(),

                    const SizedBox(height: 20),

                    Text(
                      "ORDER ITEMS",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: BlocBuilder<MenuBloc, MenuState>(
                        builder: (context, menuState) {
                          final menuItems = menuState is MenuLoaded
                              ? menuState.items
                              : const <MenuItemModel>[];

                          final orderState = context.watch<OrderBloc>().state;
                          List<OrderModel> originalOrders = [order];
                          if (orderState is OrderLoaded) {
                            final orderIds = order.id.split(',');
                            originalOrders = orderState.items
                                .where((o) => orderIds.contains(o.id))
                                .toList();
                          }
                          if (originalOrders.isEmpty) originalOrders = [order];

                          return ListView.builder(
                            itemCount: originalOrders.length,
                            itemBuilder: (context, index) {
                              final origOrder = originalOrders[index];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (originalOrders.length > 1)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 12,
                                        top: index > 0 ? 16 : 0,
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
                                    final imageUrl = _resolveItemImageUrl(
                                      item,
                                      menuItems,
                                    );

                                    return Card(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerLowest,
                                      elevation: 0,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outlineVariant,
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                          backgroundImage: imageUrl != null
                                              ? NetworkImage(imageUrl)
                                              : null,
                                          child: imageUrl == null
                                              ? Text(
                                                  item.quantity.toString(),
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : null,
                                        ),

                                        title: Text(
                                          "${item.quantity}x ${item.name}",
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),

                                        subtitle: Text(
                                          item.notes.isEmpty
                                              ? "No Notes"
                                              : item.notes,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),

                                        trailing: Text(
                                          "\$${item.price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //-----------------------------------
            // RIGHT SIDE
            //-----------------------------------
            const SizedBox(width: 24),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER ACTION",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 25),

                    _statusTile(
                      context,
                      "Pending",
                      order.status.index >= OrderStatus.pending.index,
                    ),

                    _statusTile(
                      context,
                      "Preparing",
                      order.status.index >= OrderStatus.preparing.index,
                    ),

                    _statusTile(
                      context,
                      "Ready",
                      order.status.index >= OrderStatus.ready.index,
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                        onPressed: order.status == OrderStatus.ready
                            ? null
                            : () {
                                OrderStatus newStatus = order.status;

                                switch (order.status) {
                                  case OrderStatus.pending:
                                    newStatus = OrderStatus.preparing;
                                    break;
                                  case OrderStatus.preparing:
                                    newStatus = OrderStatus.ready;
                                    break;
                                  case OrderStatus.ready:
                                    return;
                                  default:
                                    return;
                                }

                                final orderState = context
                                    .read<OrderBloc>()
                                    .state;
                                if (orderState is OrderLoaded) {
                                  final orderIds = order.id.split(',');
                                  final originalOrders = orderState.items
                                      .where((o) => orderIds.contains(o.id))
                                      .toList();

                                  final timestamp = Timestamp.now();
                                  for (var origOrder in originalOrders) {
                                    if (origOrder.status == order.status) {
                                      final updatedOrder = origOrder.copyWith(
                                        status: newStatus,
                                        updatedAt: timestamp,
                                      );
                                      BlocProvider.of<OrderBloc>(
                                        context,
                                      ).add(UpdateOrder(item: updatedOrder));
                                    }
                                  }
                                }

                                Navigator.pop(context);
                              },
                        child: Text(
                          _buttonText(order.status),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusTile(BuildContext context, String title, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done
                ? Colors.green
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: done
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String? _resolveItemImageUrl(
    OrderItemModel item,
    List<MenuItemModel> menuItems,
  ) {
    if (item.imageUrl.isNotEmpty) {
      return item.imageUrl;
    }

    for (final menuItem in menuItems) {
      if (menuItem.id == item.menuItemId && menuItem.imageUrl.isNotEmpty) {
        return menuItem.imageUrl;
      }
    }

    return null;
  }

  String _buttonText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "START PREPARING";

      case OrderStatus.preparing:
        return "MARK AS READY";

      case OrderStatus.ready:
        return "ORDER READY";

      case OrderStatus.served:
        return "ORDER SERVED";

      case OrderStatus.paid:
        return "ORDER PAID";

      case OrderStatus.cancelled:
        return "ORDER CANCELLED";
    }
  }
}
