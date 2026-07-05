import 'package:flutter/material.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/features/cashier/views/desktop/home%20widgets/cashier_top_bar.dart';
import 'package:rmss/features/cashier/views/desktop/menu%20widgets/menu_item_panel.dart';
import 'package:rmss/features/cashier/views/desktop/menu%20widgets/menu_top_bar.dart';

class Menu extends StatefulWidget {
  final TableModel? preSelectedTable;
  const Menu({super.key, this.preSelectedTable});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final TextEditingController searchController = TextEditingController();
  TableModel? currentTable;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // These top widgets are now fixed and will not scroll
            const CashierTopBar(),
            const SizedBox(height: 32),
            MenuTopBar(
              searchController: searchController,
              preSelectedTable: widget.preSelectedTable,
              onTableSelected: (selectedTable) {
                setState(() {
                  currentTable = selectedTable;
                });
              },
            ),
            const SizedBox(height: 20),

            // 2. Wrapped MenuItemPanel in Expanded and SingleChildScrollView
            Expanded(child: MenuItemPanel(searchController: searchController)),
          ],
        ),
      ),
    );
  }
}
