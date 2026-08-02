import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_state.dart';
import 'package:rmss/core/utils/order_utils.dart';

class HourlyVolumeChart extends StatelessWidget {
  final DateTime selectedDate;

  const HourlyVolumeChart({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        // Initialize buckets for each 2-hour window
        Map<int, int> orderCounts = {
          8: 0,
          10: 0,
          12: 0,
          14: 0,
          16: 0,
          18: 0,
          20: 0,
          22: 0,
        };

        if (state is OrderLoaded) {
          final groupedOrders = OrderUtils.groupActiveOrdersByTable(state.items);
          for (var order in groupedOrders) {
            DateTime orderDate = order.createdAt.toDate();
            // Filter by the selected date
            if (orderDate.year == selectedDate.year &&
                orderDate.month == selectedDate.month &&
                orderDate.day == selectedDate.day) {
              int hour = orderDate.hour;
              // Group into 2-hour buckets (e.g. 8AM-9AM -> 8, 10AM-11AM -> 10)
              int bucketHour = (hour % 2 == 1) ? hour - 1 : hour;

              if (orderCounts.containsKey(bucketHour)) {
                orderCounts[bucketHour] = orderCounts[bucketHour]! + 1;
              } else if (bucketHour < 8) {
                // If it's earlier than 8 AM, count it in the first bucket
                orderCounts[8] = orderCounts[8]! + 1;
              } else if (bucketHour > 22) {
                // If it's later than 11 PM, count it in the last bucket
                orderCounts[22] = orderCounts[22]! + 1;
              }
            }
          }
        }

        // Find the maximum number of orders to calculate the percentage heights
        int maxOrders = 0;
        for (var count in orderCounts.values) {
          if (count > maxOrders) {
            maxOrders = count;
          }
        }

        // Prevent division by zero if there are no orders
        if (maxOrders == 0) maxOrders = 1;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Hourly Order Volume",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBar(context, "8A", orderCounts[8]!, maxOrders),
                      _buildBar(context, "10A", orderCounts[10]!, maxOrders),
                      _buildBar(context, "12P", orderCounts[12]!, maxOrders),
                      _buildBar(context, "2P", orderCounts[14]!, maxOrders),
                      _buildBar(context, "4P", orderCounts[16]!, maxOrders),
                      _buildBar(context, "6P", orderCounts[18]!, maxOrders),
                      _buildBar(context, "8P", orderCounts[20]!, maxOrders),
                      _buildBar(context, "10P", orderCounts[22]!, maxOrders),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(
    BuildContext context,
    String label,
    int count,
    int maxOrders,
  ) {
    double percentage = count / maxOrders;
    if (percentage < 0.02)
      percentage =
          0.02; // Ensure minimum height to avoid zero-height layout errors

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Tooltip(
                message: '$count Orders',
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: percentage,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
