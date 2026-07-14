import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/payment_model.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/cashier/views/desktop/home%20widgets/cashier_top_bar.dart';
import 'package:rmss/features/cashier/views/desktop/home%20widgets/live_table_grid.dart';
import 'package:rmss/features/cashier/views/desktop/home%20widgets/payment_breakdown_card.dart';
import 'package:rmss/features/cashier/views/desktop/home%20widgets/recent_transactions_table.dart';
import 'package:rmss/features/cashier/views/desktop/home%20widgets/summary_card.dart';
import 'package:rmss/features/cashier/views/desktop/home%20widgets/welcome_hero.dart';
import 'package:rmss/features/cashier/views/desktop/pages/orders.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CashierTopBar(),

            const SizedBox(height: 20),

            const WelcomeHero(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, orderState) {
                        return BlocBuilder<PaymentBloc, PaymentState>(
                          builder: (context, paymentState) {
                            if (orderState is OrderLoaded &&
                                paymentState is PaymentsLoaded) {
                              final authState = context.read<AuthBloc>().state;
                              String myUserId = "";
                              if (authState is AuthSuccess) {
                                myUserId = authState.user.id;
                              }

                              bool isToday(DateTime date) {
                                final now = DateTime.now();
                                return date.year == now.year &&
                                    date.month == now.month &&
                                    date.day == now.day;
                              }

                              int counterOrders = 0;
                              int completedOrders = 0;
                              int unPaidTabs = 0;
                              double shiftRegister = 0;

                              for (OrderModel order in orderState.items) {
                                if (order.source == OrderSource.pos) {
                                  counterOrders += 1;
                                }

                                if (order.status == OrderStatus.served) {
                                  unPaidTabs += 1;
                                }

                                if (order.status == OrderStatus.paid) {
                                  bool orderIsToday = isToday(
                                    order.createdAt.toDate(),
                                  );
                                  bool isMine =
                                      order.createdBy['id'] == myUserId;
                                  if (orderIsToday && isMine) {
                                    completedOrders += 1;
                                  }
                                }
                              }

                              for (PaymentModel paymentModel
                                  in paymentState.items) {
                                bool paymentIsToday = isToday(
                                  paymentModel.createdAt.toDate(),
                                );

                                bool isProcessesByMe = paymentModel.processedBy
                                    .containsValue(myUserId);

                                if (paymentIsToday && isProcessesByMe) {
                                  shiftRegister += paymentModel.amountPaid;
                                }
                              }

                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SummaryCard(
                                      title: "Counter Orders",
                                      value: counterOrders.toString(),
                                      subText: "",
                                      subTextColor: Colors.transparent,
                                    ),

                                    SummaryCard(
                                      title: "COMPLETED ORDERS TODAY",
                                      value: completedOrders.toString(),
                                      subText: "",
                                      subTextColor: Colors.transparent,
                                    ),

                                    SummaryCard(
                                      title: "SHIFT REGISTER TODAY",
                                      value:
                                          "\$${shiftRegister.toStringAsFixed(2)}",
                                      subText: "Gross",
                                      subTextColor: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),

                                    SummaryCard(
                                      title: "UNPAID TABS",
                                      value: unPaidTabs.toString(),
                                      subText: "Requires Action",
                                      subTextColor: Colors.redAccent,
                                    ),
                                  ],
                                ),
                              );
                            } else if (orderState is OrderError ||
                                paymentState is PaymentError) {
                              final errorMessage = orderState is OrderError
                                  ? orderState.message
                                  : (paymentState as PaymentError).message;
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.dashboard_customize_rounded,
                                      size: 48,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Dashboard Error",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      errorMessage,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    strokeWidth: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Syncing Dashboard...",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    const IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 2, child: LiveTableGrid()),
                          const SizedBox(width: 20),
                          const Expanded(
                            flex: 1,
                            child: PaymentBreakdownCard(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const RecentTransactionsTable(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
