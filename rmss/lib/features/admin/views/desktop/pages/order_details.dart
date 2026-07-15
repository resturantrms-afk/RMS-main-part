import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_event.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_event.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_event.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/payment_model.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/features/admin/blocs/navigation_cubit/navigation_cubit.dart';

class OrderDetails extends StatelessWidget {
  final String orderId;

  const OrderDetails({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainer, // Background handled by parent
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, menuState) {
          return BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              if (state is OrderLoading) {
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
                        "Loading Order Details...",
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
              }
              if (state is OrderError) {
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
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Failed to Load Order",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
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
              if (state is OrderLoaded) {
                try {
                  // Find the specific order by ID
                  final order = state.items.firstWhere((o) => o.id == orderId);

                  // Use dynamic color matching the logic in orders.dart
                  Color statusColor = colorScheme.primary;
                  if (order.status == OrderStatus.ready ||
                      order.status == OrderStatus.cancelled ||
                      order.status == OrderStatus.paid) {
                    statusColor = colorScheme.outline;
                  }

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          left: 32,
                          right: 32,
                          top: 32,
                          bottom: 120, // Padding for bottom bar
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                colorScheme.surfaceContainerLow,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.arrow_back,

                                              size: 20,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            hoverColor: colorScheme
                                                .surfaceContainerHigh,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            "Source: ${order.source.name.toUpperCase()}",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Order Details: Table ${order.tableNumber}",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,

                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // Right side of Header
                                Row(
                                  children: [
                                    Text(
                                      "Time Elapsed",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      order.timeAgo(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    Text(
                                      "Status",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: colorScheme.outlineVariant,
                                        ),
                                      ),
                                      child: Text(
                                        order.status.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Total Summary Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "TOTAL AMOUNT DUE",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "\$${order.totalPrice.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w800,
                                          color: colorScheme.primary,
                                          shadows: [
                                            Shadow(
                                              color: colorScheme.primary
                                                  .withValues(alpha: 0.25),
                                              blurRadius: 32,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "ITEMS",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        "${order.items.length}",
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Ordered Items Section
                            Text(
                              "ORDERED ITEMS",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Divider(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Map over real OrderItems data
                            ...order.items.map((item) {
                              String imageUrl = '';
                              if (menuState is MenuLoaded) {
                                try {
                                  final menuItem = menuState.items.firstWhere(
                                    (m) => m.id == item.menuItemId,
                                  );
                                  imageUrl = menuItem.imageUrl;
                                } catch (_) {}
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildItemCard(
                                  context: context,
                                  item: item,
                                  imageUrl: imageUrl,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      // Bottom Action Bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 24,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(
                                  alpha: 0.8,
                                ),
                                border: Border(
                                  top: BorderSide(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // --- ADD THIS NEW BUTTON (ADD ITEMS) ---
                                  OutlinedButton.icon(
                                    onPressed:
                                        order.status != OrderStatus.paid &&
                                            order.status !=
                                                OrderStatus.cancelled
                                        ? () {
                                            final tableState = context
                                                .read<TableBloc>()
                                                .state;
                                            if (tableState is TablesLoaded) {
                                              try {
                                                // Find the actual TableModel based on order's tableId
                                                final table = tableState.items
                                                    .firstWhere(
                                                      (t) =>
                                                          t.id == order.tableId,
                                                    );

                                                // 1. Close the OrderDetails popup
                                                Navigator.pop(context);

                                                // 2. Switch the dashboard tab to the menu with the table selected!
                                                context
                                                    .read<NavigationCubit>()
                                                    .navigateToMenu(
                                                      preSelectedTable: table,
                                                    );
                                              } catch (_) {}
                                            }
                                          }
                                        : null,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 24,
                                      ),
                                      side: BorderSide(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      foregroundColor: colorScheme.primary,
                                    ),
                                    icon: const Icon(
                                      Icons.add_shopping_cart,
                                      size: 20,
                                    ),
                                    label: const Text(
                                      "ADD ITEMS",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  OutlinedButton(
                                    onPressed:
                                        order.status == OrderStatus.pending ||
                                            order.status ==
                                                OrderStatus.preparing
                                        ? () {
                                            // 1. Cancel the Order
                                            final updatedOrder = OrderModel(
                                              id: order.id,
                                              tableId: order.tableId,
                                              tableNumber: order.tableNumber,
                                              createdBy: order.createdBy,
                                              source: order.source,
                                              totalPrice: order.totalPrice,
                                              status: OrderStatus.cancelled,
                                              createdAt: order.createdAt,
                                              items: order.items,
                                            );
                                            context.read<OrderBloc>().add(
                                              UpdateOrder(item: updatedOrder),
                                            );

                                            // 2. Free up the Table
                                            final tableState = context
                                                .read<TableBloc>()
                                                .state;
                                            if (tableState is TablesLoaded) {
                                              try {
                                                final table = tableState.items
                                                    .firstWhere(
                                                      (t) =>
                                                          t.id == order.tableId,
                                                    );
                                                final updatedTable = TableModel(
                                                  id: table.id,
                                                  tableNumber:
                                                      table.tableNumber,
                                                  status: TableStatus
                                                      .available, // Make it available
                                                );
                                                context.read<TableBloc>().add(
                                                  UpdateTable(
                                                    item: updatedTable,
                                                  ),
                                                );
                                              } catch (_) {}
                                            }

                                            // 3. Go back
                                            Navigator.pop(context);
                                          }
                                        : null,

                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 24,
                                      ),
                                      side: BorderSide(
                                        color: colorScheme.error.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      foregroundColor: colorScheme.error,
                                    ),
                                    child: const Text(
                                      "CANCEL ORDER",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed:
                                        order.status == OrderStatus.served
                                        ? () {
                                            _showPaymentDialog(context, order);
                                          }
                                        : null,

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 48,
                                        vertical: 24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      elevation: 8,
                                      shadowColor: colorScheme.primary
                                          .withValues(alpha: 0.5),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "COMPLETE PAYMENT",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 20),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } catch (e) {
                  return const Center(
                    child: Text(
                      "Order not found",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  // Helper method using real order data and cached network image
  Widget _buildItemCard({
    required BuildContext context,
    required OrderItemModel item,
    required String imageUrl,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    // We use a fallback URL if no image is provided.
    final String displayImageUrl = imageUrl.isNotEmpty
        ? imageUrl
        : 'https://via.placeholder.com/150/2A1E17/E88328?text=${Uri.encodeComponent(item.name.substring(0, 1))}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Image Container
          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: displayImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.restaurant, color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Right: Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "${item.quantity}x",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "\$${item.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                // Display notes if they exist!
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Notes: ${item.notes}",
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Shows the popup asking for Cash or Zaad
  void _showPaymentDialog(BuildContext context, OrderModel order) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "Select Payment Method",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            "How is the payment of \$${order.totalPrice.toStringAsFixed(2)} being made?",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "CANCEL",
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                _processPaymentAndComplete(context, order, PaymentMethod.cash);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text("CASH"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                _processPaymentAndComplete(context, order, PaymentMethod.zaad);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text("ZAAD"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                _processPaymentAndComplete(context, order, PaymentMethod.edahab);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
              child: const Text("eDAHAB"),
            ),
          ],
        );
      },
    );
  }

  // Processes the entire workflow once a method is selected
  void _processPaymentAndComplete(
    BuildContext context,
    OrderModel order,
    PaymentMethod method,
  ) {
    // 1. Create Payment
    final currentUser = FirebaseAuth.instance.currentUser;
    final payment = PaymentModel(
      id: '', // Firebase will auto-generate the document ID
      orderId: order.id,
      processedBy: {
        'user': currentUser?.uid ?? 'unknown',
      }, // Logs the admin/admin
      paymentMethod: method,
      amountPaid: order.totalPrice,
      createdAt: Timestamp.now(),
    );
    context.read<PaymentBloc>().add(AddPayment(item: payment));

    // 2. Complete Order
    final updatedOrder = OrderModel(
      id: order.id,
      tableId: order.tableId,
      tableNumber: order.tableNumber,
      createdBy: order.createdBy,
      source: order.source,
      totalPrice: order.totalPrice,
      status: OrderStatus.paid,
      createdAt: order.createdAt,
      items: order.items,
    );
    context.read<OrderBloc>().add(UpdateOrder(item: updatedOrder));

    // 3. Mark Table as Needs Cleaning
    final tableState = context.read<TableBloc>().state;
    if (tableState is TablesLoaded) {
      try {
        final table = tableState.items.firstWhere((t) => t.id == order.tableId);
        final updatedTable = TableModel(
          id: table.id,
          tableNumber: table.tableNumber,
          status: TableStatus.needsCleaning, // Flag for cleaning
        );
        context.read<TableBloc>().add(UpdateTable(item: updatedTable));
      } catch (_) {}
    }

    // 4. Go Back to main dashboard
    Navigator.pop(context);
  }
}
