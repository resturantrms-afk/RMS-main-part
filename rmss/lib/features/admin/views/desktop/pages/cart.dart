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
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_event.dart';

class Cart extends StatelessWidget {
  final TableModel table;
  const Cart({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        // Pull menu items so we can show the food image from imageUrl
        return BlocBuilder<MenuBloc, MenuState>(
          builder: (context, menuState) {
            final tableNumber = table.tableNumber;
            final tableId = table.id;

            final double subtotal = cartState.totalPrice;
            final double total =
                subtotal; // Total equals subtotal without tax/gratuity

            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              body: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── TOP BAR ──────────────────────────────────────
                    Row(
                      children: [
                        // Back button
                        InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Back to Menu',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Title
                        Text(
                          tableNumber > 0
                              ? 'Order Summary — Table $tableNumber'
                              : 'Order Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        // Profile avatar (reuse from AdminTopBar style)
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            if (authState is AuthSuccess) {
                              return CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  authState.user.photoUrl,
                                ),
                              );
                            }
                            return CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── BODY ─────────────────────────────────────────
                    Expanded(
                      child: cartState.items.isEmpty
                          ? _buildEmptyState(context)
                          : Column(
                              children: [
                                // ── UPPER PART: ITEMS ─────────────────
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Current Order',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // ── ORDER ITEMS LIST ──────────────
                                        ...cartState.items.map((item) {
                                          String? imageUrl;
                                          if (menuState is MenuLoaded) {
                                            final menuItem = menuState.items
                                                .where(
                                                  (m) =>
                                                      m.id == item.menuItemId,
                                                )
                                                .firstOrNull;
                                            imageUrl = menuItem?.imageUrl;
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            child: _CartItemTile(
                                              item: item,
                                              imageUrl: imageUrl,
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // ── LOWER PART: SUMMARY CARD ─────────────────
                                Container(
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Summary',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      Divider(
                                        height: 32,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                      ),
                                      _SummaryRow(
                                        label: 'Subtotal',
                                        value:
                                            '\$${subtotal.toStringAsFixed(2)}',
                                      ),
                                      Divider(
                                        height: 32,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Balance',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            '\$${total.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 24, // Adjusted size
                                              fontWeight: FontWeight.w900,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      // ── COMPLETE ORDER BUTTON ──
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton.icon(
                                          onPressed: () => _completeOrder(
                                            context: context,
                                            cartState: cartState,
                                            tableId: tableId,
                                            tableNumber: tableNumber,
                                            total: total,
                                          ),
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 24,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.arrow_forward,
                                            size: 18,
                                          ),
                                          label: const Text('COMPLETE ORDER'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
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
        status: OrderStatus
            .pending, // Puts it back to pending so the kitchen sees the new items
        createdAt: existingOrder.createdAt, // Keep original time
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
        final table = tableState.items.firstWhere((t) => t.id == tableId);
        if (table.status != TableStatus.occupied) {
          final updatedTable = TableModel(
            id: tableId,
            tableNumber: tableNumber,
            status: TableStatus.occupied,
          );
          context.read<TableBloc>().add(UpdateTable(item: updatedTable));
        }
      } catch (_) {}
    }

    // 5. Navigate back to menu
    Navigator.pop(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items from the menu to get started',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Menu'),
          ),
        ],
      ),
    );
  }
}

// ── CART ITEM TILE ────────────────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  final OrderItemModel item;
  final String? imageUrl;

  const _CartItemTile({required this.item, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 64,
              height: 64,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      errorWidget: (_, __, ___) => _imageFallback(context),
                    )
                  : _imageFallback(context),
            ),
          ),

          const SizedBox(width: 16),

          // ── NAME & NOTES ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.notes,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 24),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                // Minus button
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () => context.read<CartBloc>().add(
                    UpdateCartItemQuantity(
                      menuItemId: item.menuItemId,
                      delta: -1,
                    ),
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                // Quantity number
                SizedBox(
                  width: 32,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                // Plus button
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () => context.read<CartBloc>().add(
                    UpdateCartItemQuantity(
                      menuItemId: item.menuItemId,
                      delta: 1,
                    ),
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // ── PRICE (min-w-[80px] from HTML) ────────────────────────────
          SizedBox(
            width: 80,
            child: Text(
              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── REMOVE BUTTON ─────────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () =>
                context.read<CartBloc>().add(RemoveFromCart(item: item)),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Icon(
                Icons.close,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.restaurant,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 32,
      ),
    );
  }
}

// ── SUMMARY ROW ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
