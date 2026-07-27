import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';

import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_state.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';
import 'package:rmss/core/models/menu_item_model.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/payment_model.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/core/models/user_model.dart';
import 'package:rmss/features/admin/blocs/ai_bloc/ai_bloc.dart';
import 'package:rmss/features/admin/blocs/ai_bloc/ai_event.dart';
import 'package:rmss/features/admin/blocs/ai_bloc/ai_state.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_bloc.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_state.dart';
import 'package:rmss/features/admin/views/desktop/pages/reports_tabs/ai_data_mining_components/editable_ai_chart_card.dart';

// ─────────────────────────────────────────────────────────────
// Time filter
// ─────────────────────────────────────────────────────────────
enum _TimeRange { today, thisWeek, thisMonth, allTime }

extension _TimeRangeLabel on _TimeRange {
  String get label {
    switch (this) {
      case _TimeRange.today:
        return 'Today';
      case _TimeRange.thisWeek:
        return 'This Week';
      case _TimeRange.thisMonth:
        return 'This Month';
      case _TimeRange.allTime:
        return 'All Time';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Computed stats for left panel
// ─────────────────────────────────────────────────────────────
class _DashStats {
  final double totalRevenue;
  final int totalOrders;
  final String topItemName;
  final int topItemUnits;
  final String topItemCategory;
  final List<double> dailyRevenue; // last N data points for sparkline

  const _DashStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.topItemName,
    required this.topItemUnits,
    required this.topItemCategory,
    required this.dailyRevenue,
  });
}

// ─────────────────────────────────────────────────────────────
// Main Tab Widget
// ─────────────────────────────────────────────────────────────
class AiDataMiningTab extends StatefulWidget {
  final GlobalKey? exportKey;

  const AiDataMiningTab({super.key, this.exportKey});

  @override
  State<AiDataMiningTab> createState() => _AiDataMiningTabState();
}

class _AiDataMiningTabState extends State<AiDataMiningTab> {
  final TextEditingController _chatController = TextEditingController();
  double _aiWidth = 350.0;
  bool _isChatVisible = true;
  _TimeRange _selected = _TimeRange.today;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────
  bool _inRange(DateTime dt) {
    final now = DateTime.now();
    switch (_selected) {
      case _TimeRange.today:
        return dt.year == now.year &&
            dt.month == now.month &&
            dt.day == now.day;
      case _TimeRange.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
        return dt.isAfter(start) || dt.isAtSameMomentAs(start);
      case _TimeRange.thisMonth:
        return dt.year == now.year && dt.month == now.month;
      case _TimeRange.allTime:
        return true;
    }
  }

  _DashStats _computeStats(
    List<OrderModel> orders,
    List<PaymentModel> payments,
  ) {
    final filteredOrders = orders
        .where(
          (o) => o.status == OrderStatus.paid && _inRange(o.updatedAt.toDate()),
        )
        .toList();

    final filteredPayments = payments
        .where(
          (p) =>
              p.status == PaymentStatus.completed &&
              _inRange(p.createdAt.toDate()),
        )
        .toList();

    // Revenue
    final totalRevenue = filteredPayments.fold<double>(
      0,
      (s, p) => s + p.amountPaid,
    );

    // Item counts
    final Map<String, int> itemUnits = {};
    for (final o in filteredOrders) {
      for (final item in o.items) {
        itemUnits[item.name] = (itemUnits[item.name] ?? 0) + item.quantity;
      }
    }

    String topItemName = 'N/A';
    int topItemUnits = 0;
    if (itemUnits.isNotEmpty) {
      final top = itemUnits.entries.reduce((a, b) => a.value > b.value ? a : b);
      topItemName = top.key;
      topItemUnits = top.value;
    }

    // Daily revenue sparkline (last 7 data points)
    final List<double> daily = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayRevenue = filteredPayments
          .where((p) {
            final dt = p.createdAt.toDate();
            return dt.year == day.year &&
                dt.month == day.month &&
                dt.day == day.day;
          })
          .fold<double>(0, (s, p) => s + p.amountPaid);
      daily.add(dayRevenue);
    }

    return _DashStats(
      totalRevenue: totalRevenue,
      totalOrders: filteredOrders.length,
      topItemName: topItemName,
      topItemUnits: topItemUnits,
      topItemCategory: 'Live Data',
      dailyRevenue: daily,
    );
  }

  Map<String, dynamic> _computeStatsForRange(
    _TimeRange range,
    List<OrderModel> orders,
    List<PaymentModel> payments,
    List<UserModel> users,
    List<TableModel> tables,
    Map<String, String> itemToCategory,
  ) {
    bool inRange(DateTime dt) {
      final now = DateTime.now();
      switch (range) {
        case _TimeRange.today:
          return dt.year == now.year && dt.month == now.month && dt.day == now.day;
        case _TimeRange.thisWeek:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
          return dt.isAfter(start) || dt.isAtSameMomentAs(start);
        case _TimeRange.thisMonth:
          return dt.year == now.year && dt.month == now.month;
        case _TimeRange.allTime:
          return true;
      }
    }

    final filteredOrders = orders.where((o) => o.status == OrderStatus.paid && inRange(o.updatedAt.toDate())).toList();
    final filteredPayments = payments.where((p) => p.status == PaymentStatus.completed && inRange(p.createdAt.toDate())).toList();

    final Map<String, int> itemCounts = {};
    double totalRev = 0;
    final Map<String, int> categoryCounts = {};
    final Map<String, int> ordersByHour = {};
    final Map<String, int> ordersBySource = {};
    final Map<String, int> cancelledItems = {};
    final Map<String, double> itemProfits = {};
    double totalPrepMinutes = 0;
    int preppedOrdersCount = 0;

    final inRangeOrders = orders.where((o) => inRange(o.updatedAt.toDate())).toList();
    for (var o in inRangeOrders) {
      if (o.status == OrderStatus.cancelled) {
        for (var item in o.items) {
          cancelledItems[item.name] = (cancelledItems[item.name] ?? 0) + item.quantity;
        }
      } else if (o.status == OrderStatus.paid) {
        final hour = o.createdAt.toDate().hour;
        final hourLabel = "${hour.toString().padLeft(2, '0')}:00";
        ordersByHour[hourLabel] = (ordersByHour[hourLabel] ?? 0) + 1;
        ordersBySource[o.source.name] = (ordersBySource[o.source.name] ?? 0) + 1;

        final diff = o.updatedAt.toDate().difference(o.createdAt.toDate()).inMinutes;
        if (diff > 0 && diff < 300) {
          totalPrepMinutes += diff;
          preppedOrdersCount++;
        }

        for (var item in o.items) {
          itemCounts[item.name] = (itemCounts[item.name] ?? 0) + item.quantity;
          final cat = itemToCategory[item.name] ?? 'Uncategorized';
          categoryCounts[cat] = (categoryCounts[cat] ?? 0) + item.quantity;
          final revenue = item.price * item.quantity;
          itemProfits[item.name] = (itemProfits[item.name] ?? 0) + (revenue * 0.70);
        }
      }
    }
    final avgPrepTime = preppedOrdersCount > 0 ? (totalPrepMinutes / preppedOrdersCount) : 0.0;

    final Map<String, double> revenueByDate = {};
    final Map<String, double> revenueByMethod = {};
    final Map<String, double> staffPerformance = {};

    for (var p in filteredPayments) {
      totalRev += p.amountPaid;
      final date = p.createdAt.toDate();
      final dateStr = "${date.month}/${date.day}";
      revenueByDate[dateStr] = (revenueByDate[dateStr] ?? 0) + p.amountPaid;
      final method = p.paymentMethod.name;
      revenueByMethod[method] = (revenueByMethod[method] ?? 0) + p.amountPaid;

      String staffName = 'Unknown';
      final staffId = p.processedBy['user'];
      if (staffId != null) {
        try {
          final u = users.firstWhere((u) => u.id == staffId);
          staffName = u.name;
        } catch (_) {
          staffName = p.processedBy['name'] ?? 'Unknown';
        }
      } else {
        staffName = p.processedBy['name'] ?? 'Unknown';
      }
      staffPerformance[staffName] = (staffPerformance[staffName] ?? 0) + p.amountPaid;
    }

    final occupiedTables = tables.where((t) => t.status != TableStatus.available).length;
    final activeStaff = users.where((u) => u.status == UserStatus.active).length;

    final Map<String, int> roleCounts = {};
    for (var u in users) {
      final roleName = u.role.toString().split('.').last;
      roleCounts[roleName] = (roleCounts[roleName] ?? 0) + 1;
    }

    final List<Map<String, dynamic>> detailedOrders = [];
    for (var o in inRangeOrders) {
      if (o.status == OrderStatus.paid) {
        String cashierName = 'Unknown';
        try {
          final p = payments.firstWhere((p) => p.orderId == o.id);
          final staffId = p.processedBy['user'];
          if (staffId != null) {
            cashierName = users.firstWhere((u) => u.id == staffId).name;
          } else {
            cashierName = p.processedBy['name'] ?? 'Unknown';
          }
        } catch (_) {
          final creatorId = o.createdBy['user'];
          if (creatorId != null) {
            try {
              cashierName = users.firstWhere((u) => u.id == creatorId).name;
            } catch (_) {}
          } else {
            cashierName = o.createdBy['name'] ?? 'Unknown';
          }
        }

        detailedOrders.add({
          "orderId": o.id,
          "totalPrice": o.totalPrice,
          "cashierName": cashierName,
          "items": o.items.map((i) => {
            "name": i.name,
            "quantity": i.quantity,
            "price": i.price,
          }).toList(),
        });
      }
    }

    return {
      "timeRange": range.label,
      "totalRevenue": totalRev,
      "revenueByDate": revenueByDate,
      "revenueByMethod": revenueByMethod,
      "itemUnitsSold": itemCounts,
      "categoryUnitsSold": categoryCounts,
      "itemProfits": itemProfits,
      "ordersByHour": ordersByHour,
      "ordersBySource": ordersBySource,
      "cancelledItems": cancelledItems,
      "avgPrepTimeMinutes": avgPrepTime,
      "staffPerformance": staffPerformance,
      "tables": {"total": tables.length, "occupied": occupiedTables},
      "users": {
        "totalStaff": users.length,
        "activeNow": activeStaff,
        "roles": roleCounts,
      },
      "detailedOrders": detailedOrders,
    };
  }

  String _buildContextData() {
    final orderState = context.read<OrderBloc>().state;
    final paymentState = context.read<PaymentBloc>().state;
    final userState = context.read<AdminUsersBloc>().state;
    final tableState = context.read<TableBloc>().state;
    final menuState = context.read<MenuBloc>().state;

    final menuItems = menuState is MenuLoaded ? menuState.items : <MenuItemModel>[];
    final Map<String, String> itemToCategory = {};
    for (var m in menuItems) {
      itemToCategory[m.name] = (m.category.isNotEmpty) ? m.category.first : 'Uncategorized';
    }

    final orders = orderState is OrderLoaded ? orderState.items : <OrderModel>[];
    final payments = paymentState is PaymentsLoaded ? paymentState.items : <PaymentModel>[];
    final users = userState is AdminUsersLoaded ? userState.allUsers : <UserModel>[];
    final tables = tableState is TablesLoaded ? tableState.items : <TableModel>[];

    final detailedUsers = users.map((u) => {
      "id": u.id,
      "name": u.name,
      "role": u.role.toString().split('.').last,
      "status": u.status.toString().split('.').last,
    }).toList();

    final rawMenu = menuItems.map((m) => {
      "name": m.name,
      "category": m.category.isNotEmpty ? m.category.first : 'Uncategorized',
      "price": m.price,
    }).toList();

    final map = {
      "today": _computeStatsForRange(_TimeRange.today, orders, payments, users, tables, itemToCategory),
      "thisWeek": _computeStatsForRange(_TimeRange.thisWeek, orders, payments, users, tables, itemToCategory),
      "thisMonth": _computeStatsForRange(_TimeRange.thisMonth, orders, payments, users, tables, itemToCategory),
      "allTime": _computeStatsForRange(_TimeRange.allTime, orders, payments, users, tables, itemToCategory),
      "rawMenu": rawMenu,
      "detailedUsers": detailedUsers,
    };
    return jsonEncode(map);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, orderState) {
        return BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, paymentState) {
            final stats = _computeStats(
              orderState is OrderLoaded ? orderState.items : [],
              paymentState is PaymentsLoaded ? paymentState.items : [],
            );

            return Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Panel: Dashboard
                    Expanded(
                      child: SingleChildScrollView(
                        child: RepaintBoundary(
                          key: widget.exportKey,
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 24,
                              right: 12,
                              top: 24,
                              left: 24,
                            ),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!_isChatVisible) const SizedBox(height: 64),
                                _buildLeftPanel(context, stats),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_isChatVisible) ...[
                      // Resize handle
                      MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _aiWidth = (_aiWidth - details.delta.dx).clamp(
                                300.0,
                                800.0,
                              );
                            });
                          },
                          child: Container(
                            width: 24,
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: Container(
                              height: 64,
                              width: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Right Panel: AI Chat
                      SizedBox(
                        width: _aiWidth,
                        child: _buildRightPanel(context),
                      ),
                    ],
                  ],
                ),
                // "Show AI Chat" button when hidden
                if (!_isChatVisible)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _isChatVisible = true),
                      icon: const Icon(Icons.smart_toy),
                      label: const Text('AI Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Left Panel
  // ─────────────────────────────────────────────────────────────
  Widget _buildLeftPanel(BuildContext context, _DashStats stats) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<AiBloc, AiState>(
      builder: (context, aiState) {
        AiCanvasData? activeData;
        if (aiState is AiReportReady) {
          activeData = aiState.canvasData;
        } else if (aiState is AiGenerating) {
          activeData = aiState.fallbackData;
        } else if (aiState is AiError) {
          activeData = aiState.fallbackData;
        }

        final hasAiCharts = activeData != null && activeData.charts.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasAiCharts)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: activeData!.charts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final chart = entry.value;
                      return EditableAiChartCard(
                        key: ObjectKey(chart),
                        index: index,
                        initialChart: chart,
                        onRemove: () {
                          context.read<AiBloc>().add(RemoveChart(index: index));
                        },
                      );
                    }).toList(),
                  );
                },
              )
            else ...[
              const SizedBox(height: 100),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_graph_rounded,
                        size: 64,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'AI Data Mining Engine',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Generate dynamic charts and uncover hidden trends.\nAsk a question in the chat to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ], // Closes else ...[
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Right Panel: AI Chat
  // ─────────────────────────────────────────────────────────────
  Widget _buildRightPanel(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.smart_toy, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chat with AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                  onPressed: () => setState(() => _isChatVisible = false),
                  tooltip: 'Hide Chat',
                ),
              ],
            ),
          ),

          // Chat History
          Expanded(
            child: BlocBuilder<AiBloc, AiState>(
              builder: (context, state) {
                if (state is AiGenerating) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: cs.primary,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Analysing data...',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                } else if (state is AiReportReady) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // User message bubble
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16, left: 32),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            state.canvasData.originalQuery,
                            style: TextStyle(color: cs.onSurface),
                          ),
                        ),
                      ),
                      // AI response bubble
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16, right: 32),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLowest,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Text(
                            state.canvasData.textReport ??
                                'Here is the analysis based on your data.',
                            style: TextStyle(color: cs.onSurface, height: 1.5),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is AiError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 40,
                            color: cs.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${state.message}',
                            style: TextStyle(color: cs.error),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // Initial state — empty prompt
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy_outlined,
                        size: 56,
                        color: cs.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ask a question to start\ndata mining',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Input Area
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickPrompt(
                            context,
                            'Generate card of top item',
                          ),
                          _buildQuickPrompt(
                            context,
                            'Generate pie chart of roles',
                          ),
                          _buildQuickPrompt(
                            context,
                            'Generate bar chart of items sold',
                          ),
                          _buildQuickPrompt(
                            context,
                            'Generate table of staff performance',
                          ),
                          _buildQuickPrompt(
                            context,
                            'Generate textual report of main course foods',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (blocContext) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: InputDecoration(
                              hintText: 'Ask me to mine your data...',
                              filled: true,
                              fillColor: cs.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                blocContext.read<AiBloc>().add(
                                  GenerateAiReport(
                                    query: value,
                                    contextData: _buildContextData(),
                                    preferredLevel: AiLevel.basic,
                                  ),
                                );
                                _chatController.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () {
                              if (_chatController.text.isNotEmpty) {
                                blocContext.read<AiBloc>().add(
                                  GenerateAiReport(
                                    query: _chatController.text,
                                    contextData: _buildContextData(),
                                    preferredLevel: AiLevel.basic,
                                  ),
                                );
                                _chatController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompt(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _chatController.text = text,
      borderRadius: BorderRadius.circular(24),
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
