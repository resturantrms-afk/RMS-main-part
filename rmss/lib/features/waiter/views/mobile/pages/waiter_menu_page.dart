import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_event.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_state.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/models/menu_item_model.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/features/waiter/views/mobile/pages/waiter_cart_page.dart';
import 'package:rmss/features/waiter/views/mobile/pages/waiter_menu_details_page.dart';

class WaiterMenuPage extends StatefulWidget {
  final TableModel table;
  const WaiterMenuPage({super.key, required this.table});

  @override
  State<WaiterMenuPage> createState() => _WaiterMenuPageState();
}

class _WaiterMenuPageState extends State<WaiterMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedCategory = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MenuItemModel> _filterItems(List<MenuItemModel> items, String query) {
    var filtered = items
        .where((item) => item.status == MenuItemStatus.available)
        .toList();
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered
          .where(
            (item) =>
                item.category.any((cat) => _selectedCategory.contains(cat)),
          )
          .toList();
    }
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (item) => item.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.8),
        elevation: 0,

        // Left side: Just the back button now
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        // Center: Title
        title: const Text(
          "Crown Restaurant",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,

        // Right side: The cart icon goes here
        actions: [
          IconButton(
            icon: BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                final totalItems = cartState.items.fold(
                  0,
                  (sum, item) => sum + item.quantity,
                );
                return Badge(
                  isLabelVisible: totalItems > 0,
                  label: Text(totalItems.toString()),
                  child: Icon(
                    Icons.shopping_cart,
                    color: Theme.of(context).colorScheme.primary,
                    size: 35,
                  ),
                );
              },
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WaiterCartPage(table: widget.table),
                ),
              );
            },
          ),
          // Optional: Add a little padding to the right edge so it doesn't touch the screen border
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, menuState) {
          if (menuState is MenuLoaded) {
            List<String> allCategories = menuState.items
                .where((item) => item.status == MenuItemStatus.available)
                .expand((item) => item.category)
                .toSet()
                .toList();

            return ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, textValue, _) {
                final filteredItems = _filterItems(
                  menuState.items,
                  textValue.text,
                );

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Search Input
                          Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLowest,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: "Search the editorial menu...",
                                hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.6),
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 12,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Categories
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              children: [
                                _buildCategoryButton(
                                  "All",
                                  _selectedCategory.isEmpty,
                                  () {
                                    setState(() => _selectedCategory.clear());
                                  },
                                ),
                                ...allCategories.map(
                                  (cat) => _buildCategoryButton(
                                    cat,
                                    _selectedCategory.contains(cat),
                                    () {
                                      setState(() {
                                        if (_selectedCategory.contains(cat)) {
                                          _selectedCategory.remove(cat);
                                        } else {
                                          _selectedCategory.add(cat);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Items Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 48,
                                  childAspectRatio: 0.7,
                                ),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              return _buildMenuItemCard(
                                context,
                                filteredItems[index],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCategoryButton(
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerLowest,
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(BuildContext context, MenuItemModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WaiterMenuDetailsPage(item: item, table: widget.table),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[800]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "\$${item.price.toStringAsFixed(2)}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartBloc>().add(
                    AddToCart(
                      item: OrderItemModel(
                        menuItemId: item.id,
                        name: item.name,
                        price: item.price,
                        quantity: 1,
                        notes: "",
                      ),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} added to cart'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 8,
                  shadowColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.4),
                ),
                child: const Text(
                  "ORDER",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
