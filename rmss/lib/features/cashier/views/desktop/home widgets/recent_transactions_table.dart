import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/models/order_model.dart';

class RecentTransactionsTable extends StatelessWidget {
  const RecentTransactionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(32),
      ),

      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Transactions",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                  ),
                ),

                TextButton(onPressed: () {}, child: const Text("View All")),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),

          const SizedBox(height: 5),

          BlocBuilder<OrderBloc, OrderState>(
            builder: (context, orderState) {
              if (orderState is OrderLoaded) {
                final orders = orderState.items.take(5);

                if (orders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        "No transactions yet today.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                } else {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            columnSpacing: 40,
                            headingTextStyle: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            columns: const [
                              DataColumn(label: Text("ORDER ID")),
                              DataColumn(label: Text("TIME")),
                              DataColumn(label: Text("TABLE")),
                              DataColumn(label: Text("AMOUNT")),
                              DataColumn(label: Text("STATUS")),
                              DataColumn(label: Text("ACTION"), numeric: true),
                            ],
                            rows: orders.map((order) {
                              final date = order.createdAt.toDate();
                              final timeString =
                                  "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                              return DataRow(
                                cells: [
                                  // Cell 1: ORDER ID
                                  DataCell(
                                    Text(
                                      "#ORD-${order.id.substring(0, 4).toUpperCase()}",
                                    ),
                                  ),

                                  // Cell 2: TIME
                                  DataCell(
                                    Text(
                                      timeString,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),

                                  // Cell 3: TABLE
                                  DataCell(
                                    Text(
                                      order.tableNumber > 0
                                          ? "Table ${order.tableNumber}"
                                          : "error",
                                    ),
                                  ),

                                  // Cell 4: AMOUNT
                                  DataCell(
                                    Text(
                                      "\$${order.totalPrice.toStringAsFixed(2)}",
                                    ),
                                  ),

                                  // Cell 5: STATUS
                                  DataCell(_buildStatusPill(context, order)),

                                  // Cell 6: ACTION
                                  DataCell(_buildActionButton(context, order)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  );
                }
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, OrderModel order) {
    String buttonText = "";

    if (order.status == OrderStatus.paid) {
      buttonText = "Receipt";
    } else if (order.status == OrderStatus.served) {
      buttonText = "Settle";
    } else if (order.status == OrderStatus.cancelled) {
      buttonText = "Details";
    } else {
      // For pending, preparing, and ready
      buttonText = "Cancel";
    }

    return OutlinedButton(
      onPressed: () {
        // You can add your logic here later depending on the buttonText!
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        buttonText,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, OrderModel order) {
    Color bgColor;
    Color textColor;

    switch (order.status) {
      case OrderStatus.paid:
        bgColor = Theme.of(context).colorScheme.primaryContainer;
        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
        break;
      case OrderStatus.cancelled:
        bgColor = Theme.of(context).colorScheme.errorContainer;
        textColor = Theme.of(context).colorScheme.onErrorContainer;
        break;
      case OrderStatus.served:
        bgColor = Theme.of(context).colorScheme.secondaryContainer;
        textColor = Theme.of(context).colorScheme.onSecondaryContainer;
        break;
      case OrderStatus.ready:
        bgColor = Theme.of(context).colorScheme.primary;
        textColor = Theme.of(context).colorScheme.onPrimary;
        break;
      default:
        // For pending and preparing
        bgColor = Theme.of(context).colorScheme.onSurface;
        textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        order.status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
