import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/blocs/menu_profile_bloc/menu_profile_bloc.dart';
import 'package:rmss/core/blocs/menu_profile_bloc/menu_profile_event.dart';
import 'package:rmss/core/models/menu_item_model.dart';
import 'package:rmss/core/models/menu_profile_model.dart';

class MenuProfileDialog extends StatefulWidget {
  final MenuProfileModel? profile;
  const MenuProfileDialog({super.key, this.profile});

  @override
  State<MenuProfileDialog> createState() => _MenuProfileDialogState();
}

class _MenuProfileDialogState extends State<MenuProfileDialog> {
  final _nameCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  List<String> _selectedItemIds = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _nameCtrl.text = widget.profile!.name;
      _selectedItemIds = List.from(widget.profile!.menuItemIds);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.menu_book, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Profile Name (e.g. Morning Menu)',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            
            // Main Body (3 columns: Categories, Available Items, Selected Items)
            Expanded(
              child: BlocBuilder<MenuBloc, MenuState>(
                builder: (context, state) {
                  if (state is MenuLoaded) {
                    final allItems = state.items;
                    
                    // Extract unique categories
                    final categories = {'All'};
                    for (var item in allItems) {
                      categories.addAll(item.category);
                    }
                    final categoryList = categories.toList()..sort();

                    // Filter available items
                    final searchQuery = _searchCtrl.text.toLowerCase();
                    final filteredItems = allItems.where((item) {
                      final matchesSearch = item.name.toLowerCase().contains(searchQuery);
                      final matchesCategory = _selectedCategory == 'All' || item.category.contains(_selectedCategory);
                      return matchesSearch && matchesCategory;
                    }).toList();

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Search & Categories
                        Container(
                          width: 250,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border(right: BorderSide(color: colorScheme.outlineVariant)),
                            color: colorScheme.surfaceContainerLowest,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _searchCtrl,
                                onChanged: (value) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Search items...',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHigh,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: categoryList.length,
                                  itemBuilder: (context, index) {
                                    final cat = categoryList[index];
                                    final isSelected = cat == _selectedCategory;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: InkWell(
                                        onTap: () => setState(() => _selectedCategory = cat),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            cat,
                                            style: TextStyle(
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Middle Column: Available Items Grid
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: colorScheme.surfaceContainer,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 200,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: 0.65,
                                    ),
                                    itemCount: filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      final isSelected = _selectedItemIds.contains(item.id);
                                      return _buildAvailableItemCard(item, isSelected, colorScheme);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right Column: Selected Items Cart
                        Container(
                          width: 320,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: colorScheme.outlineVariant)),
                            color: colorScheme.surfaceContainerLowest,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Selected Items',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_selectedItemIds.length}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: _selectedItemIds.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No items selected.\nClick + to add items.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: _selectedItemIds.length,
                                        itemBuilder: (context, index) {
                                          final itemId = _selectedItemIds[index];
                                          final item = allItems.firstWhere((i) => i.id == itemId);
                                          return _buildSelectedItemTile(item, colorScheme);
                                        },
                                      ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: () {
                                    if (_nameCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter a profile name.')),
                                      );
                                      return;
                                    }
                                    final newProfile = MenuProfileModel(
                                      id: widget.profile?.id ?? '',
                                      name: _nameCtrl.text.trim(),
                                      isActive: widget.profile?.isActive ?? false,
                                      menuItemIds: _selectedItemIds,
                                    );
                                    
                                    if (widget.profile == null) {
                                      context.read<MenuProfileBloc>().add(AddMenuProfile(profile: newProfile));
                                    } else {
                                      context.read<MenuProfileBloc>().add(UpdateMenuProfile(profile: newProfile));
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save Menu Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildAvailableItemCard(MenuItemModel item, bool isSelected, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: item.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.withValues(alpha: 0.2)),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: isSelected
                        ? OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              side: BorderSide(color: colorScheme.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedItemIds.remove(item.id);
                              });
                            },
                            child: Text('Remove', style: TextStyle(color: colorScheme.error, fontSize: 12)),
                          )
                        : FilledButton(
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: colorScheme.primaryContainer,
                              foregroundColor: colorScheme.onPrimaryContainer,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedItemIds.add(item.id);
                              });
                            },
                            child: const Text('Add +', style: TextStyle(fontSize: 12)),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedItemTile(MenuItemModel item, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.fastfood, size: 24, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20, color: colorScheme.error),
            onPressed: () {
              setState(() {
                _selectedItemIds.remove(item.id);
              });
            },
          ),
        ],
      ),
    );
  }
}
