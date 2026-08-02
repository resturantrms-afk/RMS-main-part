import 'package:rmss/core/models/order_model.dart';

class OrderUtils {
  /// Merges a list of orders (usually from the same table) into a single OrderModel for UI display.
  /// The resulting ID is a comma-separated list of the original IDs.
  static OrderModel mergeOrders(List<OrderModel> orders) {
    if (orders.isEmpty) {
      throw Exception('Cannot merge empty list of orders');
    }

    if (orders.length == 1) {
      return orders.first;
    }

    final String mergedIds = orders.map((o) => o.id).join(',');
    
    // Priority for status: pending > preparing > ready > served > paid > cancelled
    int priority(OrderStatus s) {
      switch(s) {
        case OrderStatus.pending: return 6;
        case OrderStatus.preparing: return 5;
        case OrderStatus.ready: return 4;
        case OrderStatus.served: return 3;
        case OrderStatus.paid: return 2;
        case OrderStatus.cancelled: return 1;
      }
    }

    OrderStatus highestStatus = orders.first.status;
    double totalAmount = 0.0;
    List<OrderItemModel> allItems = [];
    
    // Find the latest updatedAt to represent the merged order
    var latestUpdate = orders.first.updatedAt;

    for (var order in orders) {
      if (priority(order.status) > priority(highestStatus)) {
        highestStatus = order.status;
      }
      
      totalAmount += order.totalPrice;
      
      if (order.updatedAt.compareTo(latestUpdate) > 0) {
        latestUpdate = order.updatedAt;
      }

      // Merge items logically (combine quantities for same items with same notes)
      for (var newItem in order.items) {
        final existingIndex = allItems.indexWhere((i) => i.menuItemId == newItem.menuItemId && i.notes == newItem.notes);
        if (existingIndex >= 0) {
          allItems[existingIndex] = OrderItemModel(
            menuItemId: newItem.menuItemId,
            name: newItem.name,
            price: newItem.price,
            quantity: allItems[existingIndex].quantity + newItem.quantity,
            notes: newItem.notes,
          );
        } else {
          allItems.add(newItem);
        }
      }
    }

    return orders.first.copyWith(
      id: mergedIds,
      totalPrice: totalAmount,
      items: allItems,
      status: highestStatus,
      updatedAt: latestUpdate,
    );
  }

  /// Groups a list of active orders by their table number. Completed/Cancelled orders are grouped by tableNumber AND exact updatedAt timestamp.
  static List<OrderModel> groupActiveOrdersByTable(List<OrderModel> orders) {
    final Map<int, List<OrderModel>> activeTableMap = {};
    final Map<String, List<OrderModel>> inactiveSessionMap = {};
    final List<OrderModel> finalResult = [];

    for (var order in orders) {
      if (order.status == OrderStatus.paid || order.status == OrderStatus.cancelled) {
        // Group inactive (paid/cancelled) by tableNumber AND exact updatedAt time
        final key = '${order.tableNumber}_${order.updatedAt.toDate().millisecondsSinceEpoch}';
        if (!inactiveSessionMap.containsKey(key)) {
          inactiveSessionMap[key] = [];
        }
        inactiveSessionMap[key]!.add(order);
      } else {
        // Group active orders by tableNumber
        if (!activeTableMap.containsKey(order.tableNumber)) {
          activeTableMap[order.tableNumber] = [];
        }
        activeTableMap[order.tableNumber]!.add(order);
      }
    }
    
    // Merge the grouped active ones
    for (var groupedList in activeTableMap.values) {
      finalResult.add(mergeOrders(groupedList));
    }

    // Merge the grouped inactive ones
    for (var groupedList in inactiveSessionMap.values) {
      finalResult.add(mergeOrders(groupedList));
    }
    
    return finalResult;
  }

  /// Groups completed (paid) orders by their exact updatedAt timestamp (indicating they were paid together).
  static List<OrderModel> groupPaidOrdersBySession(List<OrderModel> paidOrders) {
    // Group by both tableNumber AND updatedAt (since they might have visited multiple times)
    final Map<String, List<OrderModel>> sessionMap = {};
    for (var order in paidOrders) {
      final key = '${order.tableNumber}_${order.updatedAt.toDate().millisecondsSinceEpoch}';
      if (!sessionMap.containsKey(key)) {
        sessionMap[key] = [];
      }
      sessionMap[key]!.add(order);
    }

    return sessionMap.values.map((orders) => mergeOrders(orders)).toList();
  }
}
