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

  Future<Map<String, dynamic>> generateAllReports() async {
    final orders = await _fetchAllOrders();
    final payments = await _fetchAllPayments();
    final menuItems = await _fetchAllMenuItems();
    final users = await _fetchAllUsers();

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

    // 3. Association Algorithm Report
    Map<String, int> pairFreq = {};
    for (var order in paidOrders) {
      final names = order.items.map((e) => e.name).toSet().toList();
      for (int i = 0; i < names.length; i++) {
        for (int j = i + 1; j < names.length; j++) {
          final p1 = names[i];
          final p2 = names[j];
          final key = p1.compareTo(p2) < 0 ? "$p1|$p2" : "$p2|$p1";
          pairFreq[key] = (pairFreq[key] ?? 0) + 1;
        }
      }
    }
    
    List<ItemPair> pairs = pairFreq.entries.map((e) {
      final parts = e.key.split('|');
      return ItemPair(item1Name: parts[0], item2Name: parts[1], frequency: e.value);
    }).toList();
    pairs.sort((a, b) => b.frequency.compareTo(a.frequency));

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
      'associationReport': AssociationAlgorithmReport(frequentlyBoughtTogether: pairs.take(10).toList()),
      'paymentLedgers': ledgerMap.values.toList(),
    };
  }
}
