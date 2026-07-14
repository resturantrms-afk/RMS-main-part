import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/menu_bloc/menu_bloc.dart';
import '../../../core/blocs/menu_bloc/menu_state.dart';
import '../../../core/blocs/order_bloc/order_bloc.dart';
import '../../../core/blocs/order_bloc/order_event.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A1E17),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2A1E17),
        elevation: 0,
        title: Text(
          "Order #${order.id}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //-----------------------------------
            // LEFT SIDE
            //-----------------------------------

            Expanded(
              flex: 2,

              child: Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: const Color(0xff1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "ORDER INFORMATION",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 25),

                    _infoTile(
                      "Table",
                      order.tableNumber.toString(),
                    ),

                    _infoTile(
                      "Source",
                      order.source,
                    ),

                    _infoTile(
                      "Status",
                      order.status.name.toUpperCase(),
                    ),

                    _infoTile(
                      "Total",
                      "\$${order.totalPrice.toStringAsFixed(2)}",
                    ),

                    const SizedBox(height: 30),

                    const Divider(),

                    const SizedBox(height: 20),

                    const Text(
                      "ORDER ITEMS",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: BlocBuilder<MenuBloc, MenuState>(
                        builder: (context, menuState) {
                          final menuItems = menuState is MenuLoaded
                              ? menuState.items
                              : const <MenuItemModel>[];

                          return ListView.builder(
                            itemCount: order.items.length,
                            itemBuilder: (context, index) {
                              final item = order.items[index];
                              final imageUrl = _resolveItemImageUrl(
                                item,
                                menuItems,
                              );

                              return Card(
                                color: const Color(0xff2A2A2A),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey.shade900,
                                    backgroundImage: imageUrl != null
                                        ? NetworkImage(imageUrl)
                                        : null,
                                    child: imageUrl == null
                                        ? Text(
                                            item.quantity.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),

                                  title: Text(
                                    item.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),

                                  subtitle: Text(
                                    item.notes.isEmpty
                                        ? "No Notes"
                                        : item.notes,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),

                                  trailing: Text(
                                    "\$${item.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
                                //-----------------------------------
            // RIGHT SIDE
            //-----------------------------------

            const SizedBox(width: 24),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xff1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ORDER ACTION",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 25),

                    _statusTile(
                      "Pending",
                      order.status.index >= OrderStatus.pending.index,
                    ),

                    _statusTile(
                      "Preparing",
                      order.status.index >= OrderStatus.preparing.index,
                    ),

                    _statusTile(
                      "Ready",
                      order.status.index >= OrderStatus.ready.index,
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: order.status == OrderStatus.ready
                            ? null
                            : () {
                                OrderStatus newStatus = order.status;

                                switch (order.status) {
                                  case OrderStatus.pending:
                                    newStatus = OrderStatus.preparing;
                                    break;
                                  case OrderStatus.preparing:
                                    newStatus = OrderStatus.ready;
                                    break;
                                  case OrderStatus.ready:
                                    return;
                                  default:
                                    return;
                                }

                                final updatedOrder = order.copyWith(status: newStatus);
                                BlocProvider.of<OrderBloc>(context)
                                    .add(UpdateOrder(item: updatedOrder));

                                Navigator.pop(context);
                              },
                        child: Text(
                          _buttonText(order.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusTile(String title, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: done ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: done ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String? _resolveItemImageUrl(
    OrderItemModel item,
    List<MenuItemModel> menuItems,
  ) {
    if (item.imageUrl.isNotEmpty) {
      return item.imageUrl;
    }

    for (final menuItem in menuItems) {
      if (menuItem.id == item.menuItemId && menuItem.imageUrl.isNotEmpty) {
        return menuItem.imageUrl;
      }
    }

    return null;
  }

  String _buttonText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "START PREPARING";

      case OrderStatus.preparing:
        return "MARK AS READY";

      case OrderStatus.ready:
        return "ORDER READY";

      case OrderStatus.served:
        return "ORDER SERVED";

      case OrderStatus.paid:
        return "ORDER PAID";

      case OrderStatus.cancelled:
        return "ORDER CANCELLED";
    }
  }
}