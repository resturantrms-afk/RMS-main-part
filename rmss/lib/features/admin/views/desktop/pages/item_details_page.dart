import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_event.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_event.dart';
import 'package:rmss/core/models/menu_item_model.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/services/api_services.dart';

class ItemDetailsPage extends StatefulWidget {
  final MenuItemModel item;

  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late String _imageUrl;
  late List<String> _categories;
  late MenuItemStatus _status;

  bool _isUploading = false;
  bool _isHoveringPhoto = false;
  bool _isEditingName = false;

  int _quantity = 1;
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(
      text: widget.item.description,
    );
    _priceController = TextEditingController(
      text: widget.item.price.toString(),
    );
    _imageUrl = widget.item.imageUrl;
    _categories = List.from(widget.item.category);
    _status = widget.item.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      final url = await ApiServices.uploadImage(File(pickedFile.path));
      if (url != null) {
        setState(() {
          _imageUrl = url;
          _isUploading = false;
        });
      } else {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
      }
    }
  }

  void _updateItem() {
    final updatedItem = MenuItemModel(
      id: widget.item.id,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? widget.item.price,
      imageUrl: _imageUrl,
      category: _categories,
      status: _status,
    );
    context.read<MenuBloc>().add(UpdateMenuItem(item: updatedItem));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item updated successfully')));
  }

  @override
  Widget build(BuildContext context) {
    final double currentPrice =
        double.tryParse(_priceController.text) ?? widget.item.price;
    final double totalPrice = currentPrice * _quantity;

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainer, // Uses full page background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          32,
          0,
          32,
          32,
        ), // Fills the screen with nice margins
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── LEFT SIDE: LARGE IMAGE ──
            Expanded(
              flex: 1, // Takes up exactly half the screen
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _isHoveringPhoto = true),
                    onExit: (_) => setState(() => _isHoveringPhoto = false),
                    child: GestureDetector(
                      onTap: _isUploading ? null : _pickImage,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _imageUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.restaurant, size: 80),
                                )
                              : const Icon(Icons.restaurant, size: 80),
                          if (_isHoveringPhoto || _isUploading)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isUploading)
                                      const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    else ...[
                                      const Icon(
                                        Icons.photo_camera,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "CHANGE IMAGE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 48), // Clean gap between image and text
            // ── RIGHT SIDE: DETAILS & BUTTONS ──
            Expanded(
              flex: 1, // Takes up the other half
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Title (Larger for full screen)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            hintText: 'Item Name',
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (val) {
                            if (!_isEditingName) {
                              setState(() => _isEditingName = true);
                            }
                          },
                          onTapOutside: (_) {
                            setState(() => _isEditingName = false);
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                      Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Row(
                    children: [
                      Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                      Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // The Pill-Shaped Availability Toggle
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _status = MenuItemStatus.available;
                            });
                          },
                          borderRadius: BorderRadius.circular(50),
                          mouseCursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _status == MenuItemStatus.available
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _status == MenuItemStatus.available
                                    ? Colors.green
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _status = MenuItemStatus.unavailable;
                            });
                          },
                          borderRadius: BorderRadius.circular(50),
                          mouseCursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _status == MenuItemStatus.unavailable
                                  ? Colors.red.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'Unavailable',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _status == MenuItemStatus.unavailable
                                    ? Colors.red
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category Tags
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ..._categories.map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cat.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _categories.remove(cat);
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      // Add new category menu anchor
                      Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: BlocBuilder<MenuBloc, MenuState>(
                          builder: (context, menuState) {
                            List<String> allCategories = [];
                            if (menuState is MenuLoaded) {
                              allCategories = menuState.items
                                  .expand((item) => item.category)
                                  .map((c) => c.toLowerCase())
                                  .toSet()
                                  .toList();
                              allCategories.removeWhere(
                                (cat) => _categories.any(
                                  (c) => c.toLowerCase() == cat.toLowerCase(),
                                ),
                              );
                            }

                            final query = _categoryController.text
                                .toLowerCase();
                            final availableCategories = allCategories
                                .where((cat) => !_categories.contains(cat))
                                .where((cat) => cat.contains(query))
                                .toList();

                            return MenuAnchor(
                              menuChildren: availableCategories.map((cat) {
                                return MenuItemButton(
                                  onPressed: () {
                                    setState(() {
                                      _categories.add(cat.toLowerCase());
                                      _categoryController.clear();
                                    });
                                  },
                                  child: Text(cat.toUpperCase()),
                                );
                              }).toList(),
                              builder: (context, controller, child) {
                                return TextField(
                                  controller: _categoryController,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '+ ADD',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  onTap: () {
                                    if (!controller.isOpen) {
                                      controller.open();
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {});
                                    if (!controller.isOpen) {
                                      controller.open();
                                    }
                                  },
                                  onSubmitted: (value) {
                                    if (value.isNotEmpty &&
                                        !_categories.contains(
                                          value.toLowerCase(),
                                        )) {
                                      setState(() {
                                        _categories.add(value.toLowerCase());
                                      });
                                    }
                                    _categoryController.clear();
                                    controller.close();
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Description Label
                  const Text(
                    'description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Text
                  Expanded(
                    child: Stack(
                      children: [
                        TextField(
                          controller: _descriptionController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.6,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            hintText: 'No description available.',
                            contentPadding: const EdgeInsets.all(8),
                          ),
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Icon(
                            Icons.edit,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.5),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── BOTTOM ROWS: COUNTER, ADD TO ORDER, DELETE & SAVE ──
                  Column(
                    children: [
                      Row(
                        children: [
                          // The Pill-Shaped Counter
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: _decrement,
                                  borderRadius: BorderRadius.circular(50),
                                  mouseCursor: SystemMouseCursors.click,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerLow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 24,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 56,
                                  child: Text(
                                    '$_quantity',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _increment,
                                  borderRadius: BorderRadius.circular(50),
                                  mouseCursor: SystemMouseCursors.click,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 24,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Add to Order Button
                          Expanded(
                            child: SizedBox(
                              height: 68,
                              child: OutlinedButton(
                                onPressed: () {
                                  context.read<CartBloc>().add(
                                    AddToCart(
                                      item: OrderItemModel(
                                        menuItemId: widget.item.id,
                                        name: _nameController.text,
                                        price: currentPrice,
                                        quantity: _quantity,
                                        notes: "",
                                      ),
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Added to order')),
                                  );
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'ADD TO ORDER',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '\$${totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          // Delete Item Button
                          Expanded(
                            child: SizedBox(
                              height: 68,
                              child: OutlinedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Item'),
                                      content: const Text('Are you sure you wanna delete this item?'),
                                      actions: [
                                        TextButton(
                                          style: ButtonStyle(mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click)),
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('CANCEL'),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            context.read<MenuBloc>().add(DeleteMenuItem(item: widget.item));
                                            Navigator.pop(context); // close dialog
                                            Navigator.pop(context); // close item details page
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Item deleted successfully')),
                                            );
                                          },
                                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                          child: const Text('DELETE'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'DELETE ITEM',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        fontSize: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Update Item Button
                          Expanded(
                            child: SizedBox(
                              height: 68,
                              child: FilledButton(
                                onPressed: _updateItem,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'SAVE CHANGES',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
  }
}
