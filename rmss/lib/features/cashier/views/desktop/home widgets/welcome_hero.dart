import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/cashier/blocs/navigation_cubit/navigation_cubit.dart';

class WelcomeHero extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const WelcomeHero({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back, ${state.user.name}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,

                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "ROLE: ${state.user.role.name.toUpperCase()}",
                            style: TextStyle(
                              letterSpacing: 2,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ),

        Row(
          children: [
            PopupMenuButton<DateTime>(
              onSelected: onDateSelected,
              position: PopupMenuPosition.under,
              offset: const Offset(0, 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Theme.of(context).colorScheme.surfaceContainer,
              itemBuilder: (context) {
                return List.generate(7, (index) {
                  final date = DateTime.now().subtract(Duration(days: index));
                  final isToday = index == 0;
                  final isYesterday = index == 1;
                  String label = _formatDate(date);
                  if (isToday) label = "Today, $label";
                  else if (isYesterday) label = "Yesterday, $label";
                  
                  return PopupMenuItem<DateTime>(
                    value: date,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: date.day == selectedDate.day && date.month == selectedDate.month
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: date.day == selectedDate.day && date.month == selectedDate.month
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      selectedDate.day == DateTime.now().day && selectedDate.month == DateTime.now().month
                          ? "Today, ${_formatDate(selectedDate)}" 
                          : _formatDate(selectedDate),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () {
                context.read<NavigationCubit>().navigateToMenu();
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(width: 4),
                  Text(
                    "New order",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
