import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_event.dart';
import 'package:rmss/core/models/menu_item_model.dart';
import 'package:rmss/features/kitchen/Screens/kitchen_item_details_page.dart';
import 'package:rmss/features/kitchen/widget/inventory_summary.dart' as summary;
import 'package:rmss/core/theme/theme_cubit.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/kitchen/Screens/notification_screen.dart';
import 'package:rmss/features/kitchen/Screens/profile_screen.dart';

class AvailabilityScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  const AvailabilityScreen({super.key, this.onNavigate});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final TextEditingController searchController = TextEditingController();
  List<String> selectedCategory = [];
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<MenuItemModel> _filterByCategories(
    List<MenuItemModel> items,
    List<String> selected,
  ) {
    if (selected.isEmpty) return items;
    return items.where((item) {
      return (item.category as List).any(
        (cat) => selected.contains(cat.toString()),
      );
    }).toList();
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
    final Set<String> categories = {};
    for (var item in items) {
      categories.addAll((item.category as List).map((e) => e.toString()));
    }
    return categories.toList();
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        if (state is MenuLoaded) {
          // Unlike Cashier, Kitchen sees both available and unavailable items
          List<MenuItemModel> allItems = state.items;
          List<String> allCategories = _extractUniqueCategories(allItems);

          final activeItems = allItems
              .where((e) => e.status == MenuItemStatus.available)
              .length;
          final outOfStockItems = allItems
              .where((e) => e.status == MenuItemStatus.unavailable)
              .length;

          return ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController,
            builder: (context, textEditingValue, child) {
              List<MenuItemModel> filteredItems;

              if (selectedCategory.isEmpty) {
                filteredItems = allItems;
              } else {
                filteredItems = _filterByCategories(allItems, selectedCategory);
              }

              if (textEditingValue.text.isNotEmpty) {
                filteredItems = _filterBySearchQuery(
                  filteredItems,
                  textEditingValue.text,
                );
              }

              return Scaffold(
                backgroundColor: Colors.transparent,
                body: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar
                      Row(
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              if (widget.onNavigate != null) {
                                widget.onNavigate!(3);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationsScreen(),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.notifications_outlined),
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          BlocBuilder<ThemeCubit, ThemeMode>(
                            builder: (context, state) {
                              if (state == ThemeMode.dark) {
                                return IconButton(
                                  onPressed: () =>
                                      context.read<ThemeCubit>().toggleTheme(),
                                  icon: const Icon(Icons.light_mode_outlined),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                );
                              } else {
                                return IconButton(
                                  onPressed: () =>
                                      context.read<ThemeCubit>().toggleTheme(),
                                  icon: const Icon(Icons.dark_mode_outlined),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              Widget avatar = CircleAvatar(
                                radius: 18,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              );
                              if (state is AuthSuccess) {
                                String urlImage = state.user.photoUrl;
                                avatar = CircleAvatar(
                                  radius: 18,
                                  backgroundImage: CachedNetworkImageProvider(
                                    urlImage,
                                  ),
                                );
                              }
                              return GestureDetector(
                                onTap: () {
                                  if (widget.onNavigate != null) {
                                    widget.onNavigate!(2);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ProfileScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: avatar,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Search Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            width: _searchFocusNode.hasFocus ? 500 : 300,
                            child: TextField(
                              controller: searchController,
                              focusNode: _searchFocusNode,
                              decoration: InputDecoration(
                                hoverColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                hintText: "Search menu...",
                                hintStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
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
                        ],
                      ),
                      const SizedBox(height: 24),

                      summary.InventorySummary(
                        activeItems: activeItems,
                        outOfStockItems: outOfStockItems,
                      ),
                      const SizedBox(height: 24),

                      // Categories Row
                      ScrollConfiguration(
                        behavior: const MaterialScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
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
                                    searchController.clear();
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
                                        color:
                                            selectedCategory.contains(category)
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerLowest,
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
                                          color:
                                              selectedCategory.contains(
                                                category,
                                              )
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

                      // Grid of Items
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            children: [
                              ...filteredItems.map((item) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            KitchenItemDetailsPage(
                                              initialItem: item,
                                            ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: 280,
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
                                                          const Icon(
                                                            Icons.error,
                                                          ),
                                                ),
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
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
                                                // If item is unavailable, add a tint or label
                                                if (item.status ==
                                                    MenuItemStatus.unavailable)
                                                  Positioned.fill(
                                                    child: Container(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                      child: const Center(
                                                        child: Text(
                                                          'UNAVAILABLE',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 2,
                                                          ),
                                                        ),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
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
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                    Switch(
                                                      value:
                                                          item.status ==
                                                          MenuItemStatus
                                                              .available,
                                                      activeThumbColor:
                                                          Theme.of(context).colorScheme.primary,
                                                      inactiveThumbColor:
                                                          Theme.of(context).colorScheme.error,
                                                      onChanged: (bool value) {
                                                        _confirmToggle(
                                                          context,
                                                          item,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (state is MenuError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
