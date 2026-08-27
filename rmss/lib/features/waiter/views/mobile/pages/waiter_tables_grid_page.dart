import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/blocs/table_bloc/table_event.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/features/waiter/views/mobile/pages/waiter_menu_page.dart';
import 'package:rmss/features/waiter/views/mobile/pages/waiter_history_page.dart';
import 'package:rmss/core/utils/order_utils.dart';

class WaiterTablesGridPage extends StatelessWidget {
  const WaiterTablesGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a Table",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, orderState) {
                  return BlocBuilder<TableBloc, TableState>(
                    builder: (context, tableState) {
                      if (tableState is TablesLoaded) {
                        List<TableModel> tables = tableState.items;
                        tables.sort(
                          (a, b) => a.tableNumber.compareTo(b.tableNumber),
                        );
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: tables.length,
                          itemBuilder: (itemContext, index) {
                            return _buildTableTile(
                              context,
                              itemContext,
                              tables[index],
                              orderState,
                              Theme.of(context).colorScheme,
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableTile(
    BuildContext parentContext,
    BuildContext itemContext,
    TableModel table,
    OrderState orderState,
    ColorScheme colorScheme,
  ) {
    Color borderColor = Colors.transparent;
    Color bgColor = Colors.transparent;
    Color statusTextColor = Theme.of(itemContext).colorScheme.onSurface;
    String statusText = "";

    if (table.needsHelp) {
      borderColor = colorScheme.error;
      bgColor = colorScheme.error.withValues(alpha: 0.15);
      statusTextColor = colorScheme.error;
      statusText = "NEEDS HELP";
    } else if (table.status == TableStatus.occupied) {
      borderColor = Theme.of(itemContext).colorScheme.primary;
      bgColor = Theme.of(
        itemContext,
      ).colorScheme.primary.withValues(alpha: 0.15);
      statusTextColor = Theme.of(itemContext).colorScheme.primary;
      statusText = "OCCUPIED";

      if (orderState is OrderLoaded) {
        final activeOrders = orderState.items
            .where(
              (o) =>
                  o.tableId == table.id &&
                  o.status != OrderStatus.paid &&
                  o.status != OrderStatus.cancelled,
            )
            .toList();

        if (activeOrders.isNotEmpty) {
          final Set<String> statuses = activeOrders
              .map((o) => o.status.name.toUpperCase())
              .toSet();
          statusText = statuses.join(" / ");
        }
      }
    } else if (table.status == TableStatus.needsCleaning) {
      borderColor = Theme.of(itemContext).colorScheme.primaryContainer;
      bgColor = Theme.of(
        itemContext,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3);
      statusTextColor = Theme.of(itemContext).colorScheme.onPrimaryContainer;
      statusText = "CLEANING";
    } else {
      borderColor = Theme.of(itemContext).colorScheme.outlineVariant;
      bgColor = Theme.of(itemContext).colorScheme.surface;
      statusTextColor = Theme.of(itemContext).colorScheme.onSurfaceVariant;
      statusText = "AVAILABLE";
    }

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          if (table.needsHelp) {
            parentContext.read<TableBloc>().add(
              UpdateTable(item: table.copyWith(needsHelp: false)),
            );
          }

          if (table.status == TableStatus.occupied) {
            final orderState = parentContext.read<OrderBloc>().state;
            if (orderState is OrderLoaded) {
              try {
                final activeOrders = orderState.items
                    .where(
                      (o) =>
                          o.tableId == table.id &&
                          o.status != OrderStatus.paid &&
                          o.status != OrderStatus.cancelled,
                    )
                    .toList();

                if (activeOrders.isNotEmpty) {
                  final mergedOrder = OrderUtils.mergeOrders(activeOrders);
                  if (!parentContext.mounted) return;
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(
                      builder: (_) => WaiterHistoryPage(
                        orderId: mergedOrder.id,
                        table: table,
                      ),
                    ),
                  );
                } else {
                  if (!parentContext.mounted) return;
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(
                      builder: (_) => WaiterMenuPage(table: table),
                    ),
                  );
                }
              } catch (_) {
                if (!parentContext.mounted) return;
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (_) => WaiterMenuPage(table: table),
                  ),
                );
              }
            }
          } else if (table.status == TableStatus.available) {
            if (!parentContext.mounted) return;
            Navigator.push(
              parentContext,
              MaterialPageRoute(builder: (_) => WaiterMenuPage(table: table)),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "T${table.tableNumber}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: TextStyle(
                color: statusTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
