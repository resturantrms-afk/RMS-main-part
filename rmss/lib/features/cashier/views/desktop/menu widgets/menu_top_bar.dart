import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_state.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/features/cashier/views/desktop/pages/cart.dart';

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

  // if the table does not change when we click it from live grid we use this if it changes then we don't
  // @override
  // void didUpdateWidget(MenuTopBar oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.preSelectedTable != oldWidget.preSelectedTable) {
  //     setState(() {
  //       selectedTable = widget.preSelectedTable;
  //     });
  //   }
  // }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocBuilder<TableBloc, TableState>(
          builder: (context, tableState) {
            if (tableState is TablesLoaded) {
              List<TableModel> availableTables = tableState.items
                  .where((item) => item.status == TableStatus.available)
                  .toList();
              if (availableTables.isNotEmpty) {
                if (selectedTable == null) {
                  selectedTable = availableTables.first;
                } else if (!availableTables.contains(selectedTable)) {
                  selectedTable = availableTables.first;
                }

                return Container(
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
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              } else {
                return Container(
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
                );
              }
            }
            return const CircularProgressIndicator();
          },
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
              hoverColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              hintText: "Search menu",
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const Spacer(),
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
                  // 1. Shadow it locally to ensure safe null-checks
                  final table = selectedTable;

                  if (table != null) {
                    // 2. Guard against asynchronous context death (if inside an async function)
                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Cart(
                          table: table,
                        ), // Pass the guaranteed non-null local variable
                      ),
                    );
                  }
                },
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 30,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
