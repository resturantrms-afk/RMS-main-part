import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_event.dart';

import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_event.dart';
import 'package:rmss/core/blocs/menu_profile_bloc/menu_profile_bloc.dart';
import 'package:rmss/core/blocs/menu_profile_bloc/menu_profile_state.dart';
import 'package:rmss/core/models/menu_item_model.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/features/cashier/views/desktop/pages/item_details_page.dart';

class MenuItemPanel extends StatefulWidget {
  final TextEditingController searchController;
  const MenuItemPanel({super.key, required this.searchController});

  @override
  State<MenuItemPanel> createState() => _MenuItemPanelState();
}

class _MenuItemPanelState extends State<MenuItemPanel> {
  List<String> selectedCategory = [];
  int _availabilityTabIndex = 0; // 0: Available, 1: Unavailable

  Future<void> _confirmToggle(BuildContext context, MenuItemModel item) async {
    if (item.status == MenuItemStatus.available) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm'),
          content: Text(
            'Are you sure you want to make ${item.name} unavailable?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      if (confirm == true && context.mounted) {
        context.read<MenuBloc>().add(ToggleMenuAvailability(item: item));
      }
    } else {
      context.read<MenuBloc>().add(ToggleMenuAvailability(item: item));
    }
  }

  List<MenuItemModel> _filterByCategories(
    List<MenuItemModel> items,
    List<String> selected,
  ) {
    if (selected.isEmpty) return items;
    return items
        .where((item) => item.category.any((cat) => selected.contains(cat)))
        .toList();
  }

  List<MenuItemModel> _filterBySearchQuery(
    List<MenuItemModel> items,
    String queryText,
  ) {
    if (queryText.isEmpty) return items;
    final String query = queryText.toLowerCase();
    return items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  List<String> _extractUniqueCategories(List<MenuItemModel> items) {
    return items.expand((item) => item.category).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        if (state is MenuLoaded) {
          List<MenuItemModel> allMenuItems = state.items;

          return BlocBuilder<MenuProfileBloc, MenuProfileState>(
            builder: (context, profileState) {
              List<MenuItemModel> allowedMenuItems = allMenuItems;
              
              if (profileState is MenuProfilesLoaded) {
                final activeProfiles = profileState.profiles.where((p) => p.isActive).toList();
                if (activeProfiles.isNotEmpty) {
                  final Set<String> activeIds = {};
                  for (var p in activeProfiles) {
                    activeIds.addAll(p.menuItemIds);
                  }
                  allowedMenuItems = allMenuItems.where((i) => activeIds.contains(i.id)).toList();
                }
              }

              final int availableCount = allowedMenuItems.where((i) => i.status == MenuItemStatus.available).length;
              final int unavailableCount = allowedMenuItems.where((i) => i.status == MenuItemStatus.unavailable).length;

              List<String> allCategories = _extractUniqueCategories(allowedMenuItems);

              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.searchController,
                builder: (context, textEditingValue, child) {
                  List<MenuItemModel> filteredItems;

                  if (selectedCategory.isEmpty) {
                    filteredItems = allowedMenuItems;
                  } else {
                    filteredItems = _filterByCategories(
                      allowedMenuItems,
                      selectedCategory,
                    );
                  }

                  // 2. Use the live text value directly from the builder stream
                  if (textEditingValue.text.isNotEmpty) {
                    filteredItems = _filterBySearchQuery(
                      filteredItems,
                      textEditingValue.text,
                    );
                  }

                  // Apply availability tab filter
                  if (_availabilityTabIndex == 0) {
                    filteredItems = filteredItems
                        .where((item) => item.status == MenuItemStatus.available)
                        .toList();
                  } else {
                    filteredItems = filteredItems
                        .where((item) => item.status == MenuItemStatus.unavailable)
                        .toList();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Availability Filter (Stat Cards)
                      Row(
                        children: [
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _availabilityTabIndex = 0;
                                  });
                                },
                                child: _StatCard(
                                  label: 'Available Items',
                                  value: '$availableCount',
                                  accentColor: const Color(0xFF4CAF50),
                                  isSelected: _availabilityTabIndex == 0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _availabilityTabIndex = 1;
                                  });
                                },
                                child: _StatCard(
                                  label: 'Unavailable Items',
                                  value: '$unavailableCount',
                                  accentColor: Theme.of(context).colorScheme.error,
                                  isSelected: _availabilityTabIndex == 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ScrollConfiguration(
                        behavior: const MaterialScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind
                                .mouse, // This enables the left-click and drag behavior!
                          },
                        ),

                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,

                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedCategory = [];
                                    widget.searchController.clear();
                                  });
                                },
                                icon: Icon(
                                  Icons.restore_outlined,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              ...allCategories.map((category) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      if (selectedCategory.contains(category)) {
                                        selectedCategory.remove(category);
                                      } else {
                                        selectedCategory.add(category);
                                      }
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selectedCategory.contains(category)
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(
                                                context,
                                              ).colorScheme.surfaceContainerLowest,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      child: Text(
                                        category.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                          color: selectedCategory.contains(category)
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 320,
                            mainAxisExtent: 380, // Fixed height to prevent overflow
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 24,
                          ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return GestureDetector(
                                  onTap: () {
                                    // Navigate to the Details Page and pass the specific item
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ItemDetailsPage(
                                          item: item,
                                        ), // Pass your MenuItemModel here
                                      ),
                                    );
                                  },
                                  child: Container(
                                    clipBehavior: Clip.antiAlias,
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
                                      foregroundDecoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 192,
                                            width: double.infinity,
                                            child: Stack(
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl: item.imageUrl,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: 192,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Icon(Icons.error),
                                                ),
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topCenter,
                                                        end: Alignment.bottomCenter,
                                                        colors: [
                                                          Colors.transparent,
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .surfaceContainerLow,
                                                        ],
                                                      ).withOpacity(0.1),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  item.description,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "\$${item.price.toStringAsFixed(2)}",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Switch(
                                                          value: item.status == MenuItemStatus.available,
                                                          activeThumbColor: Theme.of(context).colorScheme.primary,
                                                          inactiveThumbColor: Theme.of(context).colorScheme.error,
                                                          onChanged: (bool value) {
                                                            _confirmToggle(context, item);
                                                          },
                                                        ),
                                                        const SizedBox(width: 8),
                                                        IconButton(
                                                          style: IconButton.styleFrom(
                                                            backgroundColor: Theme.of(
                                                              context,
                                                            ).colorScheme.primary,
                                                            foregroundColor: Theme.of(
                                                              context,
                                                            ).colorScheme.onPrimary,
                                                            minimumSize: const Size(
                                                              40,
                                                              40,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    32,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            context
                                                                .read<CartBloc>()
                                                                .add(
                                                                  AddToCart(
                                                                    item:
                                                                        OrderItemModel(
                                                                          menuItemId:
                                                                              item.id,
                                                                          name:
                                                                              item.name,
                                                                          price: item
                                                                              .price,
                                                                          quantity: 1,
                                                                          notes: "",
                                                                        ),
                                                                  ),
                                                                );
                                                          },
                                                          icon: const Icon(Icons.add),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        } else if (state is MenuError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fastfood_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  "Menu Unreachable",
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
                ),
              ],
            ),
          );
        }

        // Fallback / MenuLoading state
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
                "Preparing Menu...",
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
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final Color accentColor;
  final bool isSelected;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accentColor,
    this.suffix,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? accentColor.withValues(alpha: 0.15)
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: accentColor, width: 2)
            : Border(left: BorderSide(color: accentColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 6),
                Text(
                  suffix!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
