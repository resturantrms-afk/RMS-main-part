import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_state.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_event.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_bloc.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_event.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/user_model.dart';
import 'package:rmss/core/utils/order_utils.dart';
import 'package:intl/intl.dart';

enum _TimeRange { today, thisWeek, thisMonth, lastMonth, allTime, custom }

extension _TimeRangeLabel on _TimeRange {
  String get label {
    switch (this) {
      case _TimeRange.today:
        return 'Today';
      case _TimeRange.thisWeek:
        return 'This Week';
      case _TimeRange.thisMonth:
        return 'This Month';
      case _TimeRange.lastMonth:
        return 'Last Month';
      case _TimeRange.allTime:
        return 'All Time';
      case _TimeRange.custom:
        return 'Custom';
    }
  }
}

class OrdersReportTab extends StatefulWidget {
  final GlobalKey? exportKey;

  const OrdersReportTab({super.key, this.exportKey});

  @override
  State<OrdersReportTab> createState() => _OrdersReportTabState();
}

class _OrdersReportTabState extends State<OrdersReportTab> {
  _TimeRange _selectedTime = _TimeRange.allTime;
  DateTime? _startDate;
  DateTime? _endDate;
  
  String _selectedUserId = 'All Users';
  
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersBloc>().add(LoadAllUsers());
      context.read<PaymentBloc>().add(LoadPayments());
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<AdminUsersBloc, AdminUsersState>(
      builder: (context, userState) {
        
        List<UserModel> eligibleUsers = [];
        if (userState is AdminUsersLoaded) {
          eligibleUsers = userState.allUsers
              .where((u) => u.role.name.toLowerCase() == 'admin' || u.role.name.toLowerCase() == 'cashier')
              .toList();
        }

        return BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, paymentState) {
            
            return BlocBuilder<OrderBloc, OrderState>(
              builder: (context, orderState) {
                if (orderState is OrderLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (orderState is OrderError) {
                  return Center(child: Text('Error: ${orderState.message}'));
                } else if (orderState is OrderLoaded) {
                  
                  List<OrderModel> groupedOrders = OrderUtils.groupActiveOrdersByTable(orderState.items);

                  // Apply Filters
                  List<OrderModel> filteredOrders = groupedOrders.where((order) {
                    
                    if (order.status == OrderStatus.cancelled) return false;

                    // User / Role resolution logic
                    String userId = order.createdBy['id']?.toString() ?? '';
                    if (userId.isEmpty || order.source == OrderSource.web) {
                      if (paymentState is PaymentsLoaded) {
                        final payment = paymentState.items.where((p) => p.orderId == order.id || order.id.contains(p.orderId)).firstOrNull;
                        if (payment != null) {
                          userId = payment.processedBy['user']?.toString() ?? payment.processedBy['id']?.toString() ?? '';
                        }
                      }
                    }

                    // Search Filter
                    bool matchesSearch = true;
                    if (_searchQuery.isNotEmpty) {
                      matchesSearch = order.id.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                      userId.toLowerCase().contains(_searchQuery.toLowerCase());
                    }

                    // User Filter
                    bool matchesUser = true;
                    if (_selectedUserId != 'All Users') {
                      matchesUser = userId == _selectedUserId;
                    }

                    // Date Filter
                    bool matchesDate = true;
                    DateTime orderDate = order.updatedAt.toDate();
                    DateTime now = DateTime.now();

                    if (_selectedTime == _TimeRange.today) {
                      matchesDate = orderDate.year == now.year &&
                                    orderDate.month == now.month &&
                                    orderDate.day == now.day;
                    } else if (_selectedTime == _TimeRange.thisWeek) {
                      final weekStart = now.subtract(Duration(days: now.weekday - 1));
                      matchesDate = orderDate.isAfter(DateTime(weekStart.year, weekStart.month, weekStart.day).subtract(const Duration(seconds: 1)));
                    } else if (_selectedTime == _TimeRange.thisMonth) {
                      matchesDate = orderDate.year == now.year && orderDate.month == now.month;
                    } else if (_selectedTime == _TimeRange.lastMonth) {
                      int lastMonthYear = now.month == 1 ? now.year - 1 : now.year;
                      int lastMonth = now.month == 1 ? 12 : now.month - 1;
                      matchesDate = orderDate.year == lastMonthYear && orderDate.month == lastMonth;
                    } else if (_selectedTime == _TimeRange.custom && _startDate != null && _endDate != null) {
                      matchesDate = orderDate.isAfter(_startDate!.subtract(const Duration(seconds: 1))) &&
                                    orderDate.isBefore(_endDate!.add(const Duration(seconds: 1)));
                    }

                    return matchesUser && matchesSearch && matchesDate;
                  }).toList();

                  filteredOrders.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

                  double grandTotal = filteredOrders.fold(0, (sum, order) => sum + order.totalPrice);

                  return SingleChildScrollView(
                    child: RepaintBoundary(
                      key: widget.exportKey,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        color: cs.surfaceContainer,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Filters Row
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Time Filters
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _TimeRange.values.map((r) {
                                    final isActive = r == _selectedTime;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(
                                          r == _TimeRange.custom && _startDate != null && _endDate != null && isActive
                                              ? '${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}'
                                              : r.label,
                                          style: TextStyle(
                                            fontSize: 12, 
                                            fontWeight: FontWeight.bold,
                                            color: isActive ? cs.onPrimary : cs.onSurfaceVariant
                                          ),
                                        ),
                                        selected: isActive,
                                        selectedColor: cs.primary,
                                        backgroundColor: cs.surfaceContainerHigh,
                                        onSelected: (selected) async {
                                          if (selected) {
                                            if (r == _TimeRange.custom) {
                                              final picked = await showDateRangePicker(
                                                context: context,
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime.now(),
                                              );
                                              if (picked != null) {
                                                setState(() {
                                                  _selectedTime = r;
                                                  _startDate = picked.start;
                                                  _endDate = picked.end.add(const Duration(hours: 23, minutes: 59, seconds: 59));
                                                });
                                              }
                                            } else {
                                              setState(() {
                                                _selectedTime = r;
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                                
                                // User Role Filter
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedUserId,
                                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: 'All Users',
                                          child: Text('All Users'),
                                        ),
                                        ...eligibleUsers.map((user) {
                                          return DropdownMenuItem(
                                            value: user.id,
                                            child: Text(user.name),
                                          );
                                        }),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedUserId = val);
                                      },
                                    ),
                                  ),
                                ),

                                // Search Bar
                                SizedBox(
                                  width: 300,
                                  height: 40,
                                  child: TextField(
                                    style: const TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText: 'Search report/order IDs...',
                                      hintStyle: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                                      prefixIcon: Icon(Icons.search, size: 18, color: cs.onSurfaceVariant),
                                      filled: true,
                                      fillColor: cs.surfaceContainerHigh,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(999),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _searchQuery = val;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Table Layout
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: cs.outlineVariant),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Column(
                                  children: [
                                    // Table Header
                                    Container(
                                      color: cs.surfaceContainerHigh,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                      child: Row(
                                        children: [
                                          Expanded(flex: 30, child: _headerText(context, 'REPORT ID')),
                                          Expanded(flex: 25, child: _headerText(context, 'MADE/PROCESSED BY')),
                                          Expanded(flex: 25, child: _headerText(context, 'DATE COMPLETED')),
                                          Expanded(flex: 20, child: _headerText(context, 'ORDER TOTAL', align: TextAlign.right)),
                                        ],
                                      ),
                                    ),
                                    
                                    // Table Rows
                                    if (filteredOrders.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(64),
                                        child: Center(
                                          child: Text(
                                            'No reports matching the criteria.',
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      )
                                    else
                                      ...filteredOrders.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final order = entry.value;
                                        final isLast = index == filteredOrders.length - 1;
                                        
                                        // Resolve user details
                                        String resolveUserStr(String uId, String fallback) {
                                          if (uId.isEmpty) return fallback.isNotEmpty ? fallback : 'Unknown';
                                          if (userState is AdminUsersLoaded) {
                                              final user = userState.allUsers.where((u) => u.id == uId).firstOrNull;
                                              final name = user?.name ?? (fallback.isNotEmpty ? fallback : 'Unknown');
                                              final shortId = uId.length > 5 ? uId.substring(0, 5) : uId;
                                              return '$name - #$shortId';
                                          }
                                          final shortId = uId.length > 5 ? uId.substring(0, 5) : uId;
                                          return '${fallback.isNotEmpty ? fallback : 'Unknown'} - #$shortId';
                                        }

                                        String creatorStr = '';
                                        if (order.source == OrderSource.web) {
                                            creatorStr = 'The Web';
                                        } else {
                                            String cId = order.createdBy['id']?.toString() ?? '';
                                            String cFallback = order.createdBy['name']?.toString() ?? '';
                                            creatorStr = resolveUserStr(cId, cFallback);
                                        }

                                        String processorStr = 'Unknown';
                                        if (paymentState is PaymentsLoaded) {
                                            final payment = paymentState.items.where((p) => p.orderId == order.id || order.id.contains(p.orderId)).firstOrNull;
                                            if (payment != null) {
                                                String pId = payment.processedBy['user']?.toString() ?? payment.processedBy['id']?.toString() ?? '';
                                                String pFallback = payment.processedBy['name']?.toString() ?? '';
                                                processorStr = resolveUserStr(pId, pFallback);
                                            }
                                        }

                                        final dateStr = DateFormat('MMM d, y h:mm a').format(order.updatedAt.toDate());
                                        final shortOrderId = order.id.length > 8 ? order.id.substring(0, 8) : order.id;
                                        
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Top Row
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Expanded(
                                                        flex: 30, 
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.receipt_long, size: 16, color: cs.primary),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              shortOrderId, 
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w700,
                                                                color: cs.onSurfaceVariant,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 25, 
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            if (creatorStr == processorStr)
                                                              Text(
                                                                creatorStr,
                                                                style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: cs.onSurface,
                                                                ),
                                                              )
                                                            else ...[
                                                              Text(
                                                                'Made: $creatorStr',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: cs.onSurface,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 2),
                                                              Text(
                                                                'Processed: $processorStr',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: cs.onSurfaceVariant,
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 25, 
                                                        child: Text(
                                                          dateStr, 
                                                          style: TextStyle(
                                                            fontSize: 13, 
                                                            fontWeight: FontWeight.w500,
                                                            color: cs.onSurfaceVariant,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 20, 
                                                        child: Text(
                                                          '\$${order.totalPrice.toStringAsFixed(2)}', 
                                                          textAlign: TextAlign.right,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w800,
                                                            color: cs.onSurface,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  
                                                  // Sub-Row for Items List
                                                  const SizedBox(height: 16),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                    decoration: BoxDecoration(
                                                      color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        ...order.items.map((i) {
                                                          return Padding(
                                                            padding: const EdgeInsets.only(bottom: 6),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(
                                                                  '${i.quantity}x ${i.name}',
                                                                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                                                                ),
                                                                Text(
                                                                  '\$${(i.price * i.quantity).toStringAsFixed(2)}',
                                                                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                        Divider(color: cs.outlineVariant.withValues(alpha: 0.5), height: 16),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              'TOTAL:',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.w800,
                                                                letterSpacing: 1.2,
                                                                color: cs.onSurfaceVariant,
                                                              ),
                                                            ),
                                                            Text(
                                                              '\$${order.totalPrice.toStringAsFixed(2)}', 
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w800,
                                                                color: cs.onSurface,
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
                                            if (!isLast)
                                              Divider(
                                                height: 1, 
                                                thickness: 1, 
                                                color: cs.outlineVariant.withValues(alpha: 0.25),
                                              ),
                                          ],
                                        );
                                      }),
                                      
                                    // Summary Footer
                                    if (filteredOrders.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                        decoration: BoxDecoration(
                                          color: cs.primary.withValues(alpha: 0.05),
                                          border: Border(
                                            top: BorderSide(color: cs.primary.withValues(alpha: 0.2)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              'TOTAL OF ALL ORDERS',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1.4,
                                                color: cs.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 24),
                                            Text(
                                              '\$${grandTotal.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900,
                                                color: cs.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            );
          },
        );
      },
    );
  }

  Widget _headerText(BuildContext context, String label, {TextAlign align = TextAlign.left}) {
    return Text(
      label,
      textAlign: align,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
