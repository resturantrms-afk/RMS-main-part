import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_state.dart';
import 'package:rmss/core/repositories/order_repository.dart';
import 'package:rmss/core/repositories/payment_repository.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_top_bar.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/payment_breakdown_card.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/recent_transactions_table.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/summary_card.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_welcome_hero.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/hourly_volume_chart.dart';
import 'package:rmss/core/services/ai_services.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  DateTime selectedDate = DateTime.now();

  String? _aiInsight;
  DateTime? _lastInsightFetchTime;
  bool _isFetchingInsight = false;

  Future<void> _fetchInsightIfNeeded({
    required int activeOrders,
    required int completedOrders,
    required double totalRevenue,
    required int unPaidTabs,
    required String activeOrdersPercentage,
    required String completedOrdersPercentage,
    required String revenuePercentage,
  }) async {
    if (!AiServices.isAiConnected) return;

    final now = DateTime.now();
    // Fetch if we don't have one, or if 1 hour has passed
    if (_aiInsight == null ||
        _lastInsightFetchTime == null ||
        now.difference(_lastInsightFetchTime!).inHours >= 1) {
      if (_isFetchingInsight) return;
      _isFetchingInsight = true;

      final prompt = '''
You are a restaurant AI assistant. Current stats:
- Active Orders: $activeOrders ($activeOrdersPercentage)
- Completed Orders: $completedOrders ($completedOrdersPercentage)
- Gross Revenue: \$${totalRevenue.toStringAsFixed(2)} ($revenuePercentage)
- Pending Tabs: $unPaidTabs
Write a SINGLE, very short sentence (max 8 words) providing a quick insight based on this data. Do not use quotes or introductory text.
''';

      final result = await AiServices.generateAdvice(prompt);

      if (mounted) {
        setState(() {
          _aiInsight = result;
          _lastInsightFetchTime = now;
          _isFetchingInsight = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminTopBar(),
            const SizedBox(height: 20),
            AdminWelcomeHero(
              selectedDate: selectedDate,
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),
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
                              final orderRepo = context.read<OrderRepository>();
                              final paymentRepo = context
                                  .read<PaymentRepository>();

                              int activeOrders = orderRepo.getActiveOrders(
                                orderState.items,
                              );
                              int completedOrders = orderRepo
                                  .getCompletedOrdersForDate(
                                    orderState.items,
                                    selectedDate,
                                  );
                              int unPaidTabs = orderRepo.getUnpaidTabs(
                                orderState.items,
                              );
                              double totalRevenue = paymentRepo
                                  .getTotalRevenueForDate(
                                    paymentState.items,
                                    selectedDate,
                                  );

                              String activeOrdersPercentage = orderRepo
                                  .getActiveOrdersPercentage(orderState.items);
                              String completedOrdersPercentage = orderRepo
                                  .getCompletedOrdersPercentage(
                                    orderState.items,
                                    selectedDate,
                                  );
                              String revenuePercentage = paymentRepo
                                  .getRevenuePercentage(
                                    paymentState.items,
                                    selectedDate,
                                  );

                              _fetchInsightIfNeeded(
                                activeOrders: activeOrders,
                                completedOrders: completedOrders,
                                totalRevenue: totalRevenue,
                                unPaidTabs: unPaidTabs,
                                activeOrdersPercentage: activeOrdersPercentage,
                                completedOrdersPercentage: completedOrdersPercentage,
                                revenuePercentage: revenuePercentage,
                              );

                              final bool hasAi = AiServices.isAiConnected;
                              final String aiSubText = hasAi
                                  ? (_aiInsight ?? "Analyzing data...")
                                  : "OFF";
                              final Color aiColor = hasAi
                                  ? Colors.greenAccent
                                  : Colors.redAccent;

                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SummaryCard(
                                      title: "TOTAL ACTIVE ORDERS",
                                      value: activeOrders.toString(),
                                      subText: activeOrdersPercentage,
                                      subTextColor:
                                          activeOrdersPercentage.startsWith('-')
                                          ? Colors.redAccent
                                          : Colors.greenAccent,
                                    ),

                                    SummaryCard(
                                      title: "TOTAL COMPLETED ORDERS TODAY",
                                      value: completedOrders.toString(),
                                      subText: completedOrdersPercentage,
                                      subTextColor:
                                          completedOrdersPercentage.startsWith(
                                            '-',
                                          )
                                          ? Colors.redAccent
                                          : Colors.greenAccent,
                                    ),

                                    SummaryCard(
                                      title: "TOTAL GROSS REVENUE",
                                      value:
                                          "\$${totalRevenue.toStringAsFixed(2)}",
                                      subText: revenuePercentage,
                                      subTextColor:
                                          revenuePercentage.startsWith('-')
                                          ? Colors.redAccent
                                          : Colors.greenAccent,
                                    ),

                                    SummaryCard(
                                      title: "AI INSIGHTS & PENDING TABS",
                                      value: "$unPaidTabs Pending",
                                      subText: aiSubText,
                                      subTextColor: aiColor,
                                      subTextSize: 14,
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
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: HourlyVolumeChart(
                              selectedDate: selectedDate,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 1,
                            child: PaymentBreakdownCard(
                              selectedDate: selectedDate,
                            ),
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
