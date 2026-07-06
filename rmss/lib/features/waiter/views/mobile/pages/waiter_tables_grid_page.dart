import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/features/waiter/views/mobile/pages/waiter_menu_page.dart';
import 'package:rmss/features/waiter/views/mobile/pages/waiter_history_page.dart';

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
              child: BlocBuilder<TableBloc, TableState>(
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
                      itemBuilder: (context, index) {
                        return _buildTableTile(context, tables[index]);
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableTile(BuildContext context, TableModel table) {
    Color borderColor = Colors.transparent;
    Color bgColor = Colors.transparent;
    Color statusTextColor = Theme.of(context).colorScheme.onSurface;
    String statusText = "";

    if (table.status == TableStatus.occupied) {
      borderColor = Theme.of(context).colorScheme.primary;
      bgColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
      statusTextColor = Theme.of(context).colorScheme.primary;
      statusText = "OCCUPIED";
    } else if (table.status == TableStatus.needsCleaning) {
      borderColor = Theme.of(context).colorScheme.primaryContainer;
      bgColor = Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3);
      statusTextColor = Theme.of(context).colorScheme.onPrimaryContainer;
      statusText = "CLEANING";
    } else {
      borderColor = Theme.of(context).colorScheme.outlineVariant;
      bgColor = Theme.of(context).colorScheme.surface;
      statusTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
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
          if (table.status == TableStatus.occupied) {
            final orderState = context.read<OrderBloc>().state;
            if (orderState is OrderLoaded) {
              try {
                final order = orderState.items.firstWhere(
                  (o) =>
                      o.tableId == table.id &&
                      o.status != OrderStatus.paid &&
                      o.status != OrderStatus.cancelled,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WaiterHistoryPage(orderId: order.id, table: table),
                  ),
                );
              } catch (_) {
                // If occupied but no active order found, go to menu
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WaiterMenuPage(table: table),
                  ),
                );
              }
            }
          } else if (table.status == TableStatus.available) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WaiterMenuPage(table: table),
              ),
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
