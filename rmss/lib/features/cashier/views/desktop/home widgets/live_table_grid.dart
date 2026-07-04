import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/features/cashier/blocs/navigation_cubit/navigation_cubit.dart';

class LiveTableGrid extends StatelessWidget {
  const LiveTableGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Live Floor Plan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 32),
          BlocBuilder<TableBloc, TableState>(
            builder: (context, tableState) {
              if (tableState is TablesLoaded) {
                List<TableModel> tables = tableState.items;
                tables.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
                return Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: tables
                          .map((table) => _buildTableTile(context, table))
                          .toList(),
                    ),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableTile(BuildContext context, TableModel table) {
    Color borderColor = Colors.transparent;
    Color bgColor = Colors.transparent;
    Color statusTextColor = Colors.transparent;
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
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: borderColor, width: 1),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          if (table.status == TableStatus.occupied) {
            print("Go to checkout");
          } else if (table.status == TableStatus.available) {
            context.read<NavigationCubit>().navigateToMenu(
              preSelectedTable: table,
            );
          }
        },
        child: SizedBox(
          width: 90,
          height: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "T${table.tableNumber}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 5),
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
      ),
    );
  }
}
