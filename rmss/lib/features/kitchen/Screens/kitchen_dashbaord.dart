import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/order_bloc/order_bloc.dart';
import '../../../core/blocs/order_bloc/order_state.dart';
import '../../../core/models/order_model.dart';
import '../widget/order_card.dart';
import 'order_details.dart';

class KitchenDashboard extends StatefulWidget {
  const KitchenDashboard({super.key});

  @override
  State<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends State<KitchenDashboard> {
  int _activeTab = 0;

  final List<OrderStatus> _tabs = [
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.ready,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OrderError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is! OrderLoaded) {
          return const SizedBox();
        }

        final orders = state.items;

        final currentStatus = _tabs[_activeTab];

        final displayedOrders = orders
            .where((e) => e.status == currentStatus)
            .toList();

        final pending = orders
            .where((e) => e.status == OrderStatus.pending)
            .length;

        final preparing = orders
            .where((e) => e.status == OrderStatus.preparing)
            .length;

        final ready = orders.where((e) => e.status == OrderStatus.ready).length;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //-----------------------------------
              // HEADER
              //-----------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "CROWN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "/ Kitchen",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 10, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          "Kitchen Online",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              //-----------------------------------
              // FILTERS
              //-----------------------------------
              Row(
                children: [
                  _buildTab("Pending", pending, 0),
                  const SizedBox(width: 12),
                  _buildTab("Preparing", preparing, 1),
                  const SizedBox(width: 12),
                  _buildTab("Ready", ready, 2),
                ],
              ),

              const SizedBox(height: 25),

              //-----------------------------------
              // GRID
              //-----------------------------------
              Expanded(
                child: displayedOrders.isEmpty
                    ? const Center(
                        child: Text(
                          "No Orders",
                          style: TextStyle(color: Colors.white54, fontSize: 18),
                        ),
                      )
                    : GridView.builder(
                        itemCount: displayedOrders.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: .8,
                            ),
                        itemBuilder: (_, index) {
                          final order = displayedOrders[index];

                          return OrderCard(
                            order: order,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailsScreen(order: order),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(String title, int count, int index) {
    final active = _activeTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.orange : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
