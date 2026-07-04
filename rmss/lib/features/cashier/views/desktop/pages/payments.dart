import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_state.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/models/payment_model.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/cashier/views/desktop/cashier_dashboard.dart';
import 'package:rmss/features/cashier/views/desktop/home%20widgets/cashier_top_bar.dart';

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  PaymentMethod? _selectedFilter; // null means 'All'

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
            const CashierTopBar(),
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
                    color: Colors.black.withValues(alpha: 0.5),
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
                  method: null,
                ),
                const SizedBox(width: 12),
                _buildFilterButton(
                  context: context,
                  label: "ZAAD",
                  method: PaymentMethod.zaad,
                ),
                const SizedBox(width: 12),
                _buildFilterButton(
                  context: context,
                  label: "CASH",
                  method: PaymentMethod.cash,
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
                      "Time Passed",
                      textAlign: TextAlign.right,
                    ),
                  ),
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
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (paymentState is PaymentsLoaded &&
                          orderState is OrderLoaded) {
                        // Filter payments
                        var filteredPayments = paymentState.items;
                        if (_selectedFilter != null) {
                          filteredPayments = filteredPayments
                              .where((p) => p.paymentMethod == _selectedFilter)
                              .toList();
                        }

                        // Sort by createdAt descending
                        filteredPayments.sort(
                          (a, b) => b.createdAt.compareTo(a.createdAt),
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
                            return ListView.separated(
                              itemCount: filteredPayments.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final payment = filteredPayments[index];
                                final order = orderState.items
                                    .cast<OrderModel?>()
                                    .firstWhere(
                                      (o) => o?.id == payment.orderId,
                                      orElse: () => null,
                                    );

                                return _buildPaymentRow(
                                  context,
                                  payment,
                                  order,
                                  authState,
                                );
                              },
                            );
                          },
                        );
                      }

                      if (paymentState is PaymentError) {
                        return Center(
                          child: Text("Error: ${paymentState.message}"),
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
    required PaymentMethod? method,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedFilter == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = method;
        });
      },
      borderRadius: BorderRadius.circular(999),
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
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Compute time ago for payment
    DateTime paymentTime = payment.createdAt.toDate();
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

    String userIdRaw = payment.processedBy['user'] ?? '';
    String userName = userIdRaw.length > 4
        ? "Staff ${userIdRaw.substring(0, 4).toUpperCase()}"
        : "Staff";
    String imageUrl =
        "https://ui-avatars.com/api/?name=${userName}&background=E88328&color=fff";

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
            color: Colors.black.withValues(alpha: 0.1),
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
                    userName,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      payment.paymentMethod == PaymentMethod.zaad
                          ? Icons.phone_iphone
                          : Icons.payments,
                      size: 16,
                      color: payment.paymentMethod == PaymentMethod.zaad
                          ? Colors.blue.shade400
                          : Colors.green.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      payment.paymentMethod == PaymentMethod.zaad
                          ? "Zaad"
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

          // Amount
          Expanded(
            flex: 10,
            child: Text(
              "\$${payment.amountPaid.toStringAsFixed(2)}",
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Time Passed
          Expanded(
            flex: 10,
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
        ],
      ),
    );
  }
}
