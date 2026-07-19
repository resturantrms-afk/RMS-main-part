import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_event.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/models/menu_item_model.dart';
import 'package:rmss/core/services/api_services.dart';

class AddMenuItemPopup extends StatefulWidget {
  const AddMenuItemPopup({super.key});

  @override
  State<AddMenuItemPopup> createState() => _AddMenuItemPopupState();
}

class _AddMenuItemPopupState extends State<AddMenuItemPopup> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController(); 

  String _imageUrl = '';
  List<String> _categories = [];
  MenuItemStatus _status = MenuItemStatus.available;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _descriptionController.removeListener(_onFieldChanged);
    _priceController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty &&
        double.tryParse(_priceController.text.trim()) != null &&
        _imageUrl.isNotEmpty &&
        _categories.isNotEmpty;
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

  void _submit() {
    if (_isFormValid) {
      final newItem = MenuItemModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: _imageUrl,
        category: _categories,
        status: _status,
      );

      context.read<MenuBloc>().add(AddMenuItem(item: newItem));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu item added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Menu Item', style: TextStyle(fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    image: _imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(_imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _isUploading
                      ? const Center(child: CircularProgressIndicator())
                      : _imageUrl.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                const SizedBox(height: 8),
                                Text('Upload Image', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                              ],
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(Icons.camera_alt, color: Colors.white, size: 40),
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 24),

              // Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.restaurant_menu),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Price & Status Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Status Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _status = MenuItemStatus.available),
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _status == MenuItemStatus.available ? Colors.green.withValues(alpha: 0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'Available',
                              style: TextStyle(
                                color: _status == MenuItemStatus.available ? Colors.green : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _status = MenuItemStatus.unavailable),
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _status == MenuItemStatus.unavailable ? Colors.red.withValues(alpha: 0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'Unavailable',
                              style: TextStyle(
                                color: _status == MenuItemStatus.unavailable ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Categories
              const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._categories.map((cat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cat.toUpperCase(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() => _categories.remove(cat));
                            },
                            child: Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  // MenuAnchor for adding categories
                  BlocBuilder<MenuBloc, MenuState>(
                    builder: (context, menuState) {
                      List<String> allCategories = [];
                      if (menuState is MenuLoaded) {
                        allCategories = menuState.items
                            .expand((item) => item.category)
                            .map((c) => c.toLowerCase())
                            .toSet()
                            .toList();
                        allCategories.removeWhere((cat) => _categories.any((c) => c.toLowerCase() == cat.toLowerCase()));
                      }

                      final query = _categoryController.text.toLowerCase();
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
                          return Container(
                            width: 140,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _categoryController,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                hintText: '+ ADD',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onTap: () {
                                if (!controller.isOpen) controller.open();
                              },
                              onChanged: (value) {
                                setState(() {});
                                if (!controller.isOpen) controller.open();
                              },
                              onSubmitted: (value) {
                                if (value.isNotEmpty && !_categories.contains(value.toLowerCase())) {
                                  setState(() {
                                    _categories.add(value.toLowerCase());
                                  });
                                }
                                _categoryController.clear();
                                controller.close();
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: _isFormValid ? _submit : null,
          child: const Text('ADD ITEM', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
