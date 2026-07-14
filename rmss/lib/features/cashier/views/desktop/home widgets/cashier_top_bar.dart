import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/theme/theme_cubit.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';

class CashierTopBar extends StatelessWidget {
  const CashierTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, state) {
            if (state == ThemeMode.dark) {
              return IconButton(
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                icon: const Icon(Icons.light_mode_outlined),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              );
            } else {
              return IconButton(
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                icon: const Icon(Icons.dark_mode_outlined),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              );
            }
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 16),

        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              String urlImage = state.user.photoUrl;
              return CircleAvatar(
                radius: 18,
                backgroundImage: CachedNetworkImageProvider(urlImage),
              );
            }

            return CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            );
          },
        ),
      ],
    );
  }
}
