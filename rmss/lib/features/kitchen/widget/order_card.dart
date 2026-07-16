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

  Color _statusColor() {
    switch (order.status) {
      case OrderStatus.pending:
        return Colors.orange;

      case OrderStatus.preparing:
        return Colors.blue;

      case OrderStatus.ready:
        return Colors.green;

      case OrderStatus.served:
        return Colors.purple;

      case OrderStatus.paid:
        return Colors.teal;

      case OrderStatus.cancelled:
        return Colors.red;
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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade800,
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              Text(
                order.status.name.toUpperCase(),
                style: TextStyle(
                  color: _statusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const Divider(
            color: Colors.white24,
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
                    style: const TextStyle(
                      color: Colors.white,
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
              onPressed: onTap,
              child: Text(
                _buttonText(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}