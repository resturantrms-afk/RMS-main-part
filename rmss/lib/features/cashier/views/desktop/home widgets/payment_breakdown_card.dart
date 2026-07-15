import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_state.dart';
import 'package:rmss/core/models/payment_model.dart';
import 'package:rmss/core/repositories/payment_repository.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';

class PaymentBreakdownCard extends StatelessWidget {
  final DateTime selectedDate;

  const PaymentBreakdownCard({super.key, required this.selectedDate});

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
            String myUserId = "";
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthSuccess) {
              myUserId = authState.user.id;
            }
            final myPayments = state.items.where((p) => p.processedBy['user'] == myUserId).toList();
            
            final distribution = context.read<PaymentRepository>().getPaymentMethodDistribution(myPayments, selectedDate);
            final cashPercent = distribution[PaymentMethod.cash] ?? 0;
            final zaadPercent = distribution[PaymentMethod.zaad] ?? 0;
            final edahabPercent = distribution[PaymentMethod.edahab] ?? 0;

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
                  "eDahab",
                  "${(edahabPercent * 100).toStringAsFixed(0)}%",
                  edahabPercent,
                  Theme.of(context).colorScheme.secondary,
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
