import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_event.dart';
import 'package:rmss/core/models/menu_item_model.dart';
import 'package:rmss/core/models/order_model.dart';

class ItemDetailsPage extends StatefulWidget {
  final MenuItemModel item;

  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  int _quantity = 1;

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = widget.item.price * _quantity;

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.background, // Uses full page background
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
                  child: widget.item.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.item.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.restaurant, size: 80),
                        )
                      : const Icon(Icons.restaurant, size: 80),
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
                  Text(
                    widget.item.name,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    '\$${widget.item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Tags
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: widget.item.category.map((cat) {
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
                        child: Text(
                          cat.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
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
                    child: SingleChildScrollView(
                      child: Text(
                        widget.item.description.isEmpty
                            ? 'No description available.'
                            : widget.item.description,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── BOTTOM ROW: COUNTER & ADD BUTTON ──
                  Row(
                    children: [
                      // The Pill-Shaped Counter (Scaled up slightly)
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

                      const SizedBox(width: 24),

                      // Add to Order Button (Scaled up)
                      Expanded(
                        child: SizedBox(
                          height: 68,
                          child: FilledButton(
                            onPressed: () {
                              final item = widget.item;
                              context.read<CartBloc>().add(
                                AddToCart(
                                  item: OrderItemModel(
                                    menuItemId: item.id,
                                    name: item.name,
                                    price: item.price,
                                    quantity: _quantity,
                                    notes: "",
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
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
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '\$${totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
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
            ),
          ],
        ),
      ),
    );
  }
}
