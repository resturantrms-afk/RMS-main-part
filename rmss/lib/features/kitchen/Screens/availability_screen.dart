import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_event.dart';
import 'package:rmss/core/models/menu_item_model.dart';

import 'package:rmss/features/kitchen/widget/kitchen_header.dart';
import 'package:rmss/core/constants/app_colors.dart';
import 'package:rmss/features/kitchen/widget/inventory_card.dart' as card;
import 'package:rmss/features/kitchen/widget/inventory_summary.dart' as summary;

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  String selectedCategory = "All";
  String searchText = "";

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF8C42),
      ),
    );
  }

  final List<String> categories = [
    "All",
    "Burgers",
    "Pizza",
    "Pasta",
    "Drinks",
    "Desserts",
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {

        if (state is MenuLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MenuError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is! MenuLoaded) {
          return const SizedBox();
        }

        final items = state.items;

        final filteredItems = items.where((item) {
          final normalizedSearch = searchText.trim().toLowerCase();
          final categoryMatch = selectedCategory == "All" ||
              item.category
                  .map((category) => category.toLowerCase())
                  .contains(selectedCategory.toLowerCase());

          final searchMatch = normalizedSearch.isEmpty ||
              item.name.toLowerCase().contains(normalizedSearch) ||
              item.category.any(
                (category) => category.toLowerCase().contains(normalizedSearch),
              );

          return categoryMatch && searchMatch;
        }).toList();

        final activeItems = items
            .where((e) => e.status == MenuItemStatus.available)
            .length;

        final outOfStockItems = items
            .where((e) => e.status == MenuItemStatus.unavailable)
            .length;

        return Container(
          color: AppColors.cocoaBrownDark,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              const KitchenHeader(),

              const SizedBox(height: 12),

              // SEARCH + CATEGORIES on one row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Search field
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search food or drinks...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: AppColors.cocoaBrownDark,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Categories (horizontal scroll), match the search height
                  SizedBox(
                    height: 56,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((category) {
                          final selected = selectedCategory == category;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                        ? AppColors.accentOrange
                                          : AppColors.cocoaBrownDark,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected ? Colors.transparent : Colors.white12,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: selected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // GRID
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          "No menu items match your search",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : GridView.builder(
                        itemCount: filteredItems.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.45,
                        ),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];

                          return card.InventoryCard(
                            name: item.name,
                            category: item.category.join(", "),
                            price: item.price,
                            available: item.status == MenuItemStatus.available,
                            imageUrl: item.imageUrl,
                            onToggle: () {
                              context.read<MenuBloc>().add(
                                ToggleMenuAvailability(item: item),
                              );
                              _showMessage(
                                item.status == MenuItemStatus.available
                                    ? "${item.name} marked out of stock"
                                    : "${item.name} marked available",
                              );
                            },
                          );
                        },
                      ),
              ),

                
              const SizedBox(height: 20),

              summary.InventorySummary(
                activeItems: activeItems,
                outOfStockItems: outOfStockItems,
              ),

            ],
          ),
        );
      },
    );
  }
}