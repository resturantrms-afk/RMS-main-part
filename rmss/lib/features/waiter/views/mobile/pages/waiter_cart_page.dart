import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_event.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_state.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_event.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_event.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';

class WaiterCartPage extends StatelessWidget {
  final TableModel table;
  const WaiterCartPage({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        return BlocBuilder<MenuBloc, MenuState>(
          builder: (context, menuState) {
            final double totalAmount = cartState.totalPrice;

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
                  "Order Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                centerTitle: true,
              ),
              body: cartState.items.isEmpty
                  ? Center(
                      child: Text(
                        "Cart is empty",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                "\$${totalAmount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.primary,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 48),
                              // Items List
                              ...cartState.items.map((item) {
                                String? imageUrl;
                                if (menuState is MenuLoaded) {
                                  final menuItem = menuState.items
                                      .where((m) => m.id == item.menuItemId)
                                      .firstOrNull;
                                  imageUrl = menuItem?.imageUrl;
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: SizedBox(
                                            width: 80,
                                            height: 80,
                                            child:
                                                imageUrl != null &&
                                                    imageUrl.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl: imageUrl,
                                                    fit: BoxFit.cover,
                                                    placeholder: (_, _) => Container(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .surfaceContainerHighest,
                                                    ),
                                                    errorWidget: (_, _, _) =>
                                                        Container(
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .surfaceContainerHighest,
                                                          child: const Icon(
                                                            Icons.restaurant,
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
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.name,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      context
                                                          .read<CartBloc>()
                                                          .add(
                                                            RemoveFromCart(
                                                              item: item,
                                                            ),
                                                          );
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 20,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (item.notes.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  item.notes,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
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
                                                            FontWeight.bold,
                                                        letterSpacing: 1.0,
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
                          ),
                        ),
                      ],
                    ),
              bottomNavigationBar: cartState.items.isEmpty
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
                        onPressed: () => _completeOrder(
                          context: context,
                          cartState: cartState,
                          tableId: table.id,
                          tableNumber: table.tableNumber,
                          total: totalAmount,
                        ),
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
                          "COMPLETE ORDER",
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
      },
    );
  }

  void _completeOrder({
    required BuildContext context,
    required CartState cartState,
    required String tableId,
    required int tableNumber,
    required double total,
  }) {
    // 1. Read OrderBloc to check for an existing active order
    final orderState = context.read<OrderBloc>().state;
    OrderModel? existingOrder;

    if (orderState is OrderLoaded) {
      try {
        existingOrder = orderState.items.firstWhere(
          (o) =>
              o.tableId == tableId &&
              o.status != OrderStatus.paid &&
              o.status != OrderStatus.cancelled,
        );
      } catch (_) {}
    }

    if (existingOrder != null) {
      // --- UPDATE EXISTING ORDER ---
      List<OrderItemModel> updatedItems = List.from(existingOrder.items);

      // Merge quantities if the item is identical (same ID, same notes)
      for (var newItem in cartState.items) {
        final index = updatedItems.indexWhere(
          (item) =>
              item.menuItemId == newItem.menuItemId &&
              item.notes == newItem.notes,
        );

        if (index != -1) {
          final existingItem = updatedItems[index];
          updatedItems[index] = OrderItemModel(
            menuItemId: existingItem.menuItemId,
            name: existingItem.name,
            price: existingItem.price,
            quantity: existingItem.quantity + newItem.quantity,
            notes: existingItem.notes,
          );
        } else {
          updatedItems.add(newItem);
        }
      }

      final updatedOrder = OrderModel(
        id: existingOrder.id,
        tableId: existingOrder.tableId,
        tableNumber: existingOrder.tableNumber,
        createdBy: existingOrder.createdBy,
        source: existingOrder.source,
        totalPrice: existingOrder.totalPrice + total,
        status: OrderStatus.pending,
        createdAt: existingOrder.createdAt,
        updatedAt: Timestamp.now(),
        items: updatedItems,
      );

      context.read<OrderBloc>().add(UpdateOrder(item: updatedOrder));
    } else {
      // --- CREATE NEW ORDER ---
      final authState = context.read<AuthBloc>().state;
      String userId = '';
      String userName = '';
      if (authState is AuthSuccess) {
        userId = authState.user.id;
        userName = authState.user.name;
      }

      final order = OrderModel(
        id: '', // Firestore auto-generates the ID
        tableId: tableId,
        tableNumber: tableNumber,
        createdBy: {'id': userId, 'name': userName},
        source: OrderSource.pos,
        totalPrice: total,
        status: OrderStatus.pending,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        items: cartState.items,
      );

      context.read<OrderBloc>().add(AddOrder(item: order));
    }

    // 3. Clear the local cart
    context.read<CartBloc>().add(ClearCart());

    // 4. Update Table Status to Occupied (if not already)
    final tableState = context.read<TableBloc>().state;
    if (tableState is TablesLoaded) {
      try {
        final tableObj = tableState.items.firstWhere((t) => t.id == tableId);
        if (tableObj.status != TableStatus.occupied) {
          final updatedTable = TableModel(
            id: tableId,
            tableNumber: tableNumber,
            status: TableStatus.occupied,
          );
          context.read<TableBloc>().add(UpdateTable(item: updatedTable));
        }
      } catch (_) {}
    }

    // 5. Navigate back to WaiterDashboardMobile
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
