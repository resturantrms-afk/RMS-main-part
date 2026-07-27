import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/payment_model.dart';
import 'package:rmss/core/models/menu_item_model.dart';
import 'package:rmss/core/models/user_model.dart';
import 'package:rmss/features/admin/models/reports/association_report.dart';
import 'package:rmss/features/admin/models/reports/category_performance_report.dart';
import 'package:rmss/features/admin/models/reports/item_importance_report.dart';
import 'package:rmss/features/admin/models/reports/payment_processing_ledger.dart';

class ReportsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<OrderModel>> _fetchAllOrders() async {
    final snapshot = await _firestore.collection('orders').get();
    return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data(), doc.id)).toList();
  }

  Future<List<PaymentModel>> _fetchAllPayments() async {
    final snapshot = await _firestore.collection('payments').get();
    return snapshot.docs.map((doc) => PaymentModel.fromJson(doc.data(), doc.id)).toList();
  }

  Future<List<MenuItemModel>> _fetchAllMenuItems() async {
    final snapshot = await _firestore.collection('menu_items').get();
    return snapshot.docs.map((doc) => MenuItemModel.fromJson(doc.data(), doc.id)).toList();
  }

  Future<List<UserModel>> _fetchAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data(), doc.id)).toList();
  }

  Future<Map<String, dynamic>> generateAllReports({DateTime? startDate, DateTime? endDate}) async {
    final allOrders = await _fetchAllOrders();
    final allPayments = await _fetchAllPayments();
    final menuItems = await _fetchAllMenuItems();
    final users = await _fetchAllUsers();

    // Filter orders by date range
    var orders = allOrders;
    if (startDate != null && endDate != null) {
      orders = orders.where((o) {
        final dt = o.updatedAt.toDate();
        return dt.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
               dt.isBefore(endDate.add(const Duration(seconds: 1)));
      }).toList();
    }

    // Filter payments by date range
    var payments = allPayments;
    if (startDate != null && endDate != null) {
      payments = payments.where((p) {
        final dt = p.createdAt.toDate();
        return dt.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
               dt.isBefore(endDate.add(const Duration(seconds: 1)));
      }).toList();
    }

    final paidOrders = orders.where((o) => o.status == OrderStatus.paid).toList();

    // 1. Item Importance Report
    Map<String, ItemImportanceReport> itemMap = {};
    for (var order in paidOrders) {
      for (var item in order.items) {
        if (!itemMap.containsKey(item.name)) {
          final menuItem = menuItems.where((m) => m.id == item.menuItemId || m.name == item.name).firstOrNull;
          final category = (menuItem != null && menuItem.category.isNotEmpty) ? menuItem.category.first : 'Uncategorized';
          itemMap[item.name] = ItemImportanceReport(
            dishName: item.name,
            firstCategory: category,
            unitsSold: 0,
            totalRevenue: 0.0,
            status: ItemPerformanceStatus.normal,
          );
        }
        final existing = itemMap[item.name]!;
        itemMap[item.name] = ItemImportanceReport(
          dishName: existing.dishName,
          firstCategory: existing.firstCategory,
          unitsSold: existing.unitsSold + item.quantity,
          totalRevenue: existing.totalRevenue + (item.quantity * item.price),
          status: ItemPerformanceStatus.normal,
        );
      }
    }

    // Determine status based on units sold logic
    if (itemMap.isNotEmpty) {
      final sortedItems = itemMap.values.toList()..sort((a, b) => b.unitsSold.compareTo(a.unitsSold));
      final topThreshold = sortedItems.first.unitsSold * 0.75;
      final bottomThreshold = sortedItems.first.unitsSold * 0.25;

      for (var key in itemMap.keys) {
        final current = itemMap[key]!;
        ItemPerformanceStatus status = ItemPerformanceStatus.normal;
        if (current.unitsSold >= topThreshold) {
          status = ItemPerformanceStatus.highPerforming;
        } else if (current.unitsSold <= bottomThreshold) {
          status = ItemPerformanceStatus.underPerforming;
        }
        itemMap[key] = ItemImportanceReport(
          dishName: current.dishName,
          firstCategory: current.firstCategory,
          unitsSold: current.unitsSold,
          totalRevenue: current.totalRevenue,
          status: status,
        );
      }
    }

    // 2. Category Performance Report
    Map<String, CategoryPerformanceReport> catMap = {};
    for (var item in itemMap.values) {
      if (!catMap.containsKey(item.firstCategory)) {
        catMap[item.firstCategory] = CategoryPerformanceReport(
          categoryName: item.firstCategory,
          totalRevenue: 0,
          itemsSold: 0,
        );
      }
      final existing = catMap[item.firstCategory]!;
      catMap[item.firstCategory] = CategoryPerformanceReport(
        categoryName: existing.categoryName,
        totalRevenue: existing.totalRevenue + item.totalRevenue,
        itemsSold: existing.itemsSold + item.unitsSold,
      );
    }

    // 3. Association Algorithm Report (Apriori - 20% support)
    final int minSupportThreshold = (paidOrders.length * 0.20).ceil();
    
    // Pass 1: Find frequent 1-itemsets
    Map<String, int> itemFreq = {};
    for (var order in paidOrders) {
      final names = order.items.map((e) => e.name).toSet();
      for (var name in names) {
        itemFreq[name] = (itemFreq[name] ?? 0) + 1;
      }
    }
    
    final Set<String> frequentItems = itemFreq.entries
        .where((e) => e.value >= minSupportThreshold)
        .map((e) => e.key)
        .toSet();

    // Pass 2: Find frequent itemsets using only frequent items
    List<List<String>> getSubsets(List<String> list) {
      List<List<String>> result = [];
      int n = list.length;
      for (int i = 1; i < (1 << n); i++) {
        List<String> subset = [];
        for (int j = 0; j < n; j++) {
          if ((i & (1 << j)) != 0) {
            subset.add(list[j]);
          }
        }
        if (subset.length >= 2) {
          result.add(subset);
        }
      }
      return result;
    }

    Map<String, int> subsetFreq = {};
    for (var order in paidOrders) {
      final names = order.items
          .map((e) => e.name)
          .where((name) => frequentItems.contains(name))
          .toSet()
          .toList();
      names.sort(); // Ensure consistent keys
          
      final subsets = getSubsets(names);
      for (var subset in subsets) {
        final key = subset.join('|');
        subsetFreq[key] = (subsetFreq[key] ?? 0) + 1;
      }
    }
    
    List<ItemSet> itemSets = subsetFreq.entries
        .where((e) => e.value >= minSupportThreshold)
        .map((e) {
      return ItemSet(items: e.key.split('|'), frequency: e.value);
    }).toList();
    
    // Sort by frequency descending, then by itemset size descending
    itemSets.sort((a, b) {
      if (b.frequency != a.frequency) {
        return b.frequency.compareTo(a.frequency);
      }
      return b.items.length.compareTo(a.items.length);
    });

    // 4. Payment Processing Ledger
    Map<String, PaymentProcessingLedger> ledgerMap = {};
    for (var payment in payments) {
      final userId = payment.processedBy['user'] ?? 'unknown';
      if (!ledgerMap.containsKey(userId)) {
        final user = users.where((u) => u.id == userId).firstOrNull;
        ledgerMap[userId] = PaymentProcessingLedger(
          userId: userId,
          userName: user?.name ?? 'Unknown',
          userRole: user?.role.name ?? 'Staff',
          totalOrdersProcessed: 0,
          totalRevenueCollected: 0.0,
          aiComment: 'Good performance.',
        );
      }
      final existing = ledgerMap[userId]!;
      ledgerMap[userId] = PaymentProcessingLedger(
        userId: existing.userId,
        userName: existing.userName,
        userRole: existing.userRole,
        totalOrdersProcessed: existing.totalOrdersProcessed + 1,
        totalRevenueCollected: existing.totalRevenueCollected + payment.amountPaid,
        aiComment: existing.aiComment,
      );
    }

    return {
      'itemImportanceReports': itemMap.values.toList(),
      'categoryPerformance': catMap.values.toList(),
      'associationReport': AssociationAlgorithmReport(frequentlyBoughtTogether: itemSets.take(10).toList()),
      'paymentLedgers': ledgerMap.values.toList(),
    };
  }
}
