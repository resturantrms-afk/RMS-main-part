import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_event.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_event.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_state.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/models/payment_model.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rmss/core/utils/order_utils.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_bloc.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_state.dart';

import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_top_bar.dart';
import 'package:rmss/features/admin/views/desktop/pages/receipt.dart';

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminTopBar(),
            const SizedBox(height: 24),
            // Page Header
            Text(
              "Payments",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                shadows: [
                  Shadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filter Buttons
            Row(
              children: [
                _buildFilterButton(
                  context: context,
                  label: "ALL",
                  filterValue: "ALL",
                ),
                const SizedBox(width: 12),
                _buildFilterButton(
                  context: context,
                  label: "ZAAD",
                  filterValue: "ZAAD",
                ),
                const SizedBox(width: 12),
                _buildFilterButton(
                  context: context,
                  label: "eDAHAB",
                  filterValue: "EDAHAB",
                ),
                const SizedBox(width: 12),
                _buildFilterButton(
                  context: context,
                  label: "CASH",
                  filterValue: "CASH",
                ),
                const SizedBox(width: 12),
                _buildFilterButton(
                  context: context,
                  label: "VOIDED",
                  filterValue: "VOIDED",
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(flex: 10, child: _buildHeaderText("Payment ID")),
                  Expanded(flex: 10, child: _buildHeaderText("Order ID")),
                  Expanded(flex: 10, child: _buildHeaderText("Table")),
                  Expanded(flex: 15, child: _buildHeaderText("Processed By")),
                  Expanded(flex: 15, child: _buildHeaderText("Method")),
                  Expanded(flex: 10, child: _buildHeaderText("Status")),
                  Expanded(
                    flex: 10,
                    child: _buildHeaderText(
                      "Amount",
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: _buildHeaderText(
                      "Created At",
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: _buildHeaderText(
                      "Last Edited",
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const Expanded(flex: 10, child: SizedBox()), // Actions
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Payments List
            Expanded(
              child: BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, paymentState) {
                  return BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, orderState) {
                      if (paymentState is PaymentsLoading ||
                          orderState is OrderLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Loading Payments...",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // And replace the PaymentError block with:
                      if (paymentState is PaymentError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.warning_rounded,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Payment Error",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                paymentState.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      if (paymentState is PaymentsLoaded &&
                          orderState is OrderLoaded) {
                        // Filter payments
                        List<PaymentModel> groupPayments(
                          List<PaymentModel> rawPayments,
                        ) {
                          final grouped = <int, List<PaymentModel>>{};
                          for (final p in rawPayments) {
                            final key = p.updatedAt
                                .toDate()
                                .millisecondsSinceEpoch;
                            grouped.putIfAbsent(key, () => []).add(p);
                          }

                          return grouped.values.map((group) {
                            if (group.length == 1) return group.first;

                            final mergedIds = group.map((e) => e.id).join(',');
                            final mergedOrderIds = group
                                .map((e) => e.orderId)
                                .join(',');
                            final totalAmount = group.fold<double>(
                              0,
                              (sum, item) => sum + item.amountPaid,
                            );

                            final status =
                                group.any(
                                  (e) => e.status == PaymentStatus.voided,
                                )
                                ? PaymentStatus.voided
                                : PaymentStatus.completed;

                            return PaymentModel(
                              id: mergedIds,
                              orderId: mergedOrderIds,
                              processedBy: group.first.processedBy,
                              paymentMethod: group.first.paymentMethod,
                              amountPaid: totalAmount,
                              status: status,
                              createdAt: group.first.createdAt,
                              updatedAt: group.first.updatedAt,
                            );
                          }).toList();
                        }

                        var filteredPayments = groupPayments(
                          paymentState.items,
                        );

                        if (_selectedFilter == "VOIDED") {
                          filteredPayments = filteredPayments
                              .where((p) => p.status == PaymentStatus.voided)
                              .toList();
                        } else {
                          // Hide voided payments from other filters
                          filteredPayments = filteredPayments
                              .where((p) => p.status != PaymentStatus.voided)
                              .toList();

                          if (_selectedFilter != "ALL") {
                            filteredPayments = filteredPayments
                                .where(
                                  (p) =>
                                      p.paymentMethod.name.toUpperCase() ==
                                      _selectedFilter,
                                )
                                .toList();
                          }
                        }

                        // Sort by updatedAt descending
                        filteredPayments.sort(
                          (a, b) => b.updatedAt.compareTo(a.updatedAt),
                        );

                        if (filteredPayments.isEmpty) {
                          return Center(
                            child: Text(
                              "No payments found.",
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        return BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            return BlocBuilder<AdminUsersBloc, AdminUsersState>(
                              builder: (context, usersState) {
                                return ListView.separated(
                                  itemCount: filteredPayments.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final payment = filteredPayments[index];
                                    final orderIds = payment.orderId.split(',');
                                    final order = orderState.items
                                        .cast<OrderModel?>()
                                        .firstWhere(
                                          (o) =>
                                              o != null &&
                                              orderIds.contains(o.id),
                                          orElse: () => null as OrderModel?,
                                        );

                                    return _buildPaymentRow(
                                      context,
                                      payment,
                                      order,
                                      authState,
                                      usersState,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required BuildContext context,
    required String label,
    required String filterValue,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedFilter == filterValue;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filterValue;
        });
      },
      borderRadius: BorderRadius.circular(999),
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
          border: isSelected
              ? null
              : Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text, {TextAlign textAlign = TextAlign.left}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPaymentRow(
    BuildContext context,
    PaymentModel payment,
    OrderModel? order,
    AuthState authState,
    AdminUsersState usersState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Compute time ago for payment based on updatedAt
    DateTime paymentTime = payment.updatedAt.toDate();
    Duration duration = DateTime.now().difference(paymentTime);
    String timePassed = "N/A";
    if (duration.inDays > 0) {
      timePassed = "${duration.inDays} days ago";
    } else if (duration.inHours > 0) {
      timePassed = "${duration.inHours} hrs ago";
    } else if (duration.inMinutes > 0) {
      timePassed = "${duration.inMinutes} mins ago";
    } else {
      timePassed = "Just now";
    }

    // Compute created at
    DateTime createdTime = payment.createdAt.toDate();
    Duration createdDuration = DateTime.now().difference(createdTime);
    String createdPassed = "N/A";
    if (createdDuration.inDays > 0) {
      createdPassed = "${createdDuration.inDays} days ago";
    } else if (createdDuration.inHours > 0) {
      createdPassed = "${createdDuration.inHours} hrs ago";
    } else if (createdDuration.inMinutes > 0) {
      createdPassed = "${createdDuration.inMinutes} mins ago";
    } else {
      createdPassed = "Just now";
    }

    String userIdRaw = payment.processedBy['user'] ?? '';
    String userName = userIdRaw.length > 4
        ? "Staff ${userIdRaw.substring(0, 4).toUpperCase()}"
        : "Staff";
    String imageUrl =
        "https://ui-avatars.com/api/?name=${userName}&background=E88328&color=fff";

    // Try finding from all users
    if (usersState is AdminUsersLoaded) {
      try {
        final staffUser = usersState.allUsers.firstWhere(
          (u) => u.id == userIdRaw,
        );
        userName = staffUser.name;
        imageUrl = staffUser.photoUrl;
      } catch (_) {
        // Fallback to AuthState below if not found
      }
    }

    if (authState is AuthSuccess) {
      if (userIdRaw == authState.user.id || userIdRaw.isEmpty) {
        userName = authState.user.name;
        imageUrl = authState.user.photoUrl;
      }
    }

    // Safely format ID substrings
    String shortPaymentId = payment.id.length > 4
        ? payment.id.substring(0, 4)
        : payment.id;
    String shortOrderId = payment.orderId.length > 4
        ? payment.orderId.substring(0, 4)
        : payment.orderId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Payment ID
          Expanded(
            flex: 10,
            child: Text(
              "#PAY-$shortPaymentId",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Order ID
          Expanded(
            flex: 10,
            child: Text(
              "#ORD-$shortOrderId",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // Table
          Expanded(
            flex: 10,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  order != null ? "TABLE ${order.tableNumber}" : "UNKNOWN",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),

          // Processed By
          Expanded(
            flex: 15,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "$userName (${userIdRaw.isNotEmpty ? userIdRaw.substring(0, 4) : 'N/A'})",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Method
          Expanded(
            flex: 15,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.05),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        payment.paymentMethod == PaymentMethod.zaad
                            ? Icons.phone_iphone
                            : payment.paymentMethod == PaymentMethod.edahab
                            ? Icons.account_balance_wallet
                            : Icons.payments,
                        size: 16,
                        color: payment.paymentMethod == PaymentMethod.zaad
                            ? Theme.of(context).colorScheme.primary
                            : payment.paymentMethod == PaymentMethod.edahab
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        payment.paymentMethod == PaymentMethod.zaad
                            ? "Zaad"
                            : payment.paymentMethod == PaymentMethod.edahab
                            ? "eDahab"
                            : "Cash",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Status
          Expanded(
            flex: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: payment.status == PaymentStatus.completed
                    ? colorScheme.primaryContainer
                    : colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                payment.status.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: payment.status == PaymentStatus.completed
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),

          // Amount
          Expanded(
            flex: 10,
            child: Text(
              "\$${payment.amountPaid.toStringAsFixed(2)}",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),

          // Time Passed (Created At)
          Expanded(
            flex: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (createdDuration.inMinutes < 60) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    createdPassed,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Time Passed (Last Edited)
          Expanded(
            flex: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (duration.inMinutes < 60) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    timePassed,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Expanded(
            flex: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: colorScheme.error,
                    tooltip: 'Delete Payment',
                    onPressed: () async {
                      if (payment.status == PaymentStatus.voided) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cannot void an already voided payment',
                            ),
                          ),
                        );
                        return;
                      }
                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Void Payment?'),
                          content: const Text(
                            'Are you sure you want to void this payment record? The order will be reverted to waiting for payment.',
                          ),
                          actions: [
                            TextButton(
                              style: ButtonStyle(
                                mouseCursor: WidgetStateProperty.all(
                                  SystemMouseCursors.click,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                mouseCursor: WidgetStateProperty.all(
                                  SystemMouseCursors.click,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Void',
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        final paymentState = context.read<PaymentBloc>().state;
                        final orderState = context.read<OrderBloc>().state;
  
                        if (paymentState is PaymentsLoaded &&
                            orderState is OrderLoaded) {
                          final paymentIds = payment.id.split(',');
                          final originalPayments = paymentState.items
                              .where((p) => paymentIds.contains(p.id))
                              .toList();
  
                          final orderIds = payment.orderId.split(',');
                          final originalOrders = orderState.items
                              .where((o) => orderIds.contains(o.id))
                              .toList();
  
                          final timestamp = Timestamp.now();
  
                          // 1. Void all original payments
                          for (var origPayment in originalPayments) {
                            final voidedPayment = origPayment.copyWith(
                              status: PaymentStatus.voided,
                              updatedAt: timestamp,
                            );
                            context.read<PaymentBloc>().add(
                              UpdatePayment(item: voidedPayment),
                            );
                          }
  
                          // 2. Revert all original orders to served
                          for (var origOrder in originalOrders) {
                            final revertedOrder = origOrder.copyWith(
                              status: OrderStatus.served,
                              updatedAt: timestamp,
                            );
                            context.read<OrderBloc>().add(
                              UpdateOrder(item: revertedOrder),
                            );
                          }
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.receipt_long),
                    color: colorScheme.primary,
                    tooltip: 'View Receipt',
                    onPressed: () {
                      if (order != null) {
                        final orderState = context.read<OrderBloc>().state;
                        if (orderState is OrderLoaded) {
                          final orderIds = payment.orderId.split(',');
                          final originalOrders = orderState.items
                              .where((o) => orderIds.contains(o.id))
                              .toList();
                          if (originalOrders.isNotEmpty) {
                            final mergedOrderForReceipt = OrderUtils.mergeOrders(
                              originalOrders,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReceiptPage(order: mergedOrderForReceipt),
                              ),
                            );
                            return;
                          }
                        }
                      }
  
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order details not found')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
