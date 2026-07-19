import 'package:flutter/material.dart';
import '../../../core/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  Color _statusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (order.status) {
      case OrderStatus.pending:
        return colorScheme.outline;

      case OrderStatus.preparing:
        return colorScheme.primary;

      case OrderStatus.ready:
        return colorScheme.secondary;

      case OrderStatus.served:
        return colorScheme.tertiary;

      case OrderStatus.paid:
        return colorScheme.tertiary;

      case OrderStatus.cancelled:
        return colorScheme.error;
    }
  }

  String _buttonText() {
    switch (order.status) {
      case OrderStatus.pending:
        return "VIEW ORDER";

      case OrderStatus.preparing:
        return "VIEW ORDER";

      case OrderStatus.ready:
        return "VIEW ORDER";

      case OrderStatus.served:
        return "VIEW ORDER";

      case OrderStatus.paid:
        return "VIEW ORDER";

      case OrderStatus.cancelled:
        return "VIEW ORDER";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TABLE ${order.tableNumber}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              Text(
                order.status.name.toUpperCase(),
                style: TextStyle(
                  color: _statusColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          Divider(
            color: Theme.of(context).colorScheme.outlineVariant,
            height: 24,
          ),

          Expanded(
            child: ListView.builder(
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "• ${item.quantity}x ${item.name}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: onTap,
              child: Text(
                _buttonText(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}