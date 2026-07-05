import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_state.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/features/cashier/views/desktop/pages/cart.dart';
import 'package:rmss/features/cashier/views/desktop/pages/order_history.dart';

class MenuTopBar extends StatefulWidget {
  final TextEditingController searchController;
  final TableModel? preSelectedTable;
  final Function(TableModel?) onTableSelected;

  const MenuTopBar({
    super.key,
    required this.searchController,
    this.preSelectedTable,
    required this.onTableSelected,
  });

  @override
  State<MenuTopBar> createState() => _MenuTopBarState();
}

class _MenuTopBarState extends State<MenuTopBar> {
  TableModel? selectedTable;

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    selectedTable = widget.preSelectedTable;

    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the entire Row inside the TableBloc builder!
    return BlocBuilder<TableBloc, TableState>(
      builder: (context, tableState) {
        if (tableState is TablesLoaded) {
          List<TableModel> availableTables = tableState.items
              .where(
                (item) =>
                    item.status == TableStatus.available ||
                    item.status == TableStatus.occupied,
              )
              .toList();

          if (availableTables.isNotEmpty) {
            // 2. Keep the selected table by ID, instead of full object comparison
            TableModel? matchingTable;
            if (selectedTable != null) {
              matchingTable = availableTables
                  .where((t) => t.id == selectedTable!.id)
                  .firstOrNull;
            }

            if (matchingTable != null) {
              // Always use the latest instance so the status stays accurate!
              selectedTable = matchingTable;
            } else {
              selectedTable = availableTables.first;
              // Safe way to notify the parent without causing build errors
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) widget.onTableSelected(selectedTable);
              });
            }
          }

          // 3. Now the Row is inside the builder, so everything draws in sync
          return Row(
            children: [
              if (availableTables.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TableModel>(
                      dropdownColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainer,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      isDense: true,
                      value: selectedTable,
                      onChanged: (value) {
                        setState(() {
                          selectedTable = value;
                          widget.onTableSelected(selectedTable);
                        });
                      },
                      items: availableTables
                          .map(
                            (item) => DropdownMenuItem<TableModel>(
                              value: item,
                              child: Text(
                                "Table ${item.tableNumber}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    "No Available Tables",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

              const SizedBox(width: 24),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: _searchFocusNode.hasFocus ? 500 : 300,
                child: TextField(
                  controller: widget.searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hoverColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHigh,
                    hintText: "Search menu",
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // This will now always have the perfect up-to-date data!
              selectedTable != null &&
                      selectedTable!.status == TableStatus.occupied
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderHistory(table: selectedTable!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history, size: 30),
                    )
                  : const SizedBox.shrink(),

              const SizedBox(width: 8),

              BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  return Badge(
                    label: Text(
                      cartState.items.fold(0, (quantity, item) {
                        return item.quantity + quantity;
                      }).toString(),
                    ),
                    isLabelVisible: cartState.items.isNotEmpty,
                    child: IconButton(
                      onPressed: () {
                        final table = selectedTable;
                        if (table != null) {
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Cart(table: table),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, size: 30),
                    ),
                  );
                },
              ),
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
