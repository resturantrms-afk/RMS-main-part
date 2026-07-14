import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_state.dart';
import 'package:rmss/core/models/payment_model.dart';

class PaymentBreakdownCard extends StatelessWidget {
  const PaymentBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(24),
      ),
      child: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          if (state is PaymentsLoaded) {
            double totalCash = 0;
            double totalZaad = 0;

            state.items.forEach((item) {
              if (item.paymentMethod == PaymentMethod.cash) {
                totalCash += item.amountPaid;
              } else {
                totalZaad += item.amountPaid;
              }
            });

            double grandTotal = totalCash + totalZaad;

            double cashPercent = grandTotal == 0 ? 0 : totalCash / grandTotal;

            double zaadPercent = grandTotal == 0 ? 0 : totalZaad / grandTotal;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Payment Breakdown",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 32),
                _buildProgressRow(
                  context,
                  "Zaad",
                  "${(zaadPercent * 100).toStringAsFixed(0)}%",
                  zaadPercent,
                  Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                _buildProgressRow(
                  context,
                  "Cash",
                  "${(cashPercent * 100).toStringAsFixed(0)}%",
                  cashPercent,
                  Theme.of(context).colorScheme.tertiary,
                ),
              ],
            );
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget _buildProgressRow(
    BuildContext context,
    String title,
    String percentText,
    double percentValue,
    Color barColor,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              percentText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentValue,
          color: barColor,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}
