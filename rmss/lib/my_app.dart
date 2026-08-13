import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_event.dart';
import 'package:rmss/core/blocs/order_bloc/order_bloc.dart';
import 'package:rmss/core/blocs/order_bloc/order_event.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_bloc.dart';
import 'package:rmss/core/blocs/payment_bloc/payment_event.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_event.dart';
import 'package:rmss/core/constants/app_config.dart';
import 'package:rmss/core/repositories/menu_repository.dart';
import 'package:rmss/core/repositories/order_repository.dart';
import 'package:rmss/core/repositories/payment_repository.dart';
import 'package:rmss/core/repositories/table_repository.dart';
import 'package:rmss/core/repositories/user_repository.dart';
import 'package:rmss/core/repositories/menu_profile_repository.dart';
import 'package:rmss/core/blocs/menu_profile_bloc/menu_profile_bloc.dart';
import 'package:rmss/core/blocs/menu_profile_bloc/menu_profile_event.dart';
import 'package:rmss/core/theme/colors.dart';

import 'package:rmss/core/theme/theme_cubit.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/repository/auth_repository.dart';
import 'package:rmss/features/auth/views/splash_screen.dart';

import 'package:rmss/features/admin/blocs/users_bloc/admin_users_bloc.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_event.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_bloc.dart';
import 'package:rmss/features/admin/repository/reports_repository.dart';
import 'package:rmss/features/admin/blocs/ai_bloc/ai_bloc.dart';
import 'package:rmss/features/admin/blocs/navigation_cubit/navigation_cubit.dart'
    as admin_nav;
import 'package:rmss/core/repositories/app_notification_repository.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_bloc.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_event.dart';
import 'package:rmss/features/cashier/blocs/navigation_cubit/navigation_cubit.dart';
import 'package:rmss/core/repositories/app_branding_repository.dart';
import 'package:rmss/core/blocs/app_branding_cubit/app_branding_cubit.dart';
import 'package:rmss/core/models/app_branding_model.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
        RepositoryProvider(create: (context) => TableRepository()),
        RepositoryProvider(create: (context) => MenuRepository()),
        RepositoryProvider(create: (context) => OrderRepository()),
        RepositoryProvider(create: (context) => PaymentRepository()),
        RepositoryProvider(create: (context) => AppNotificationRepository()),
        RepositoryProvider(create: (context) => ReportsRepository()),
        RepositoryProvider(create: (context) => AppBrandingRepository()),
        RepositoryProvider(create: (context) => MenuProfileRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => NavigationCubit()),
          BlocProvider(create: (context) => admin_nav.NavigationCubit()),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                AdminUsersBloc(userRepository: context.read<UserRepository>())
                  ..add(LoadAllUsers()),
          ),
          BlocProvider(
            create: (context) => ReportsBloc(
              reportsRepository: context.read<ReportsRepository>(),
            ),
          ),
          BlocProvider(create: (context) => AiBloc()),
          BlocProvider(
            create: (context) =>
                MenuBloc(repository: context.read<MenuRepository>())
                  ..add(LoadMenu()),
          ),
          BlocProvider(
            create: (context) =>
                MenuProfileBloc(repository: context.read<MenuProfileRepository>())
                  ..add(LoadMenuProfiles()),
          ),
          BlocProvider(
            create: (context) =>
                OrderBloc(repository: context.read<OrderRepository>())
                  ..add(LoadOrder()),
          ),
          BlocProvider(
            create: (context) =>
                TableBloc(repository: context.read<TableRepository>())
                  ..add(LoadTables()),
          ),
          BlocProvider(
            create: (context) =>
                PaymentBloc(repository: context.read<PaymentRepository>())
                  ..add(LoadPayments()),
          ),
          BlocProvider(create: (context) => CartBloc()),
          BlocProvider(
            create: (context) => AppNotificationBloc(
              repository: context.read<AppNotificationRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => AppBrandingCubit(
              repository: context.read<AppBrandingRepository>(),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeState) {
            return BlocBuilder<AppBrandingCubit, AppBrandingModel>(
              builder: (context, brandingState) {
                return MaterialApp(
                  title: brandingState.appName.isNotEmpty ? brandingState.appName : AppConfig.appName,
                  debugShowCheckedModeBanner: false,
                  darkTheme: AppTheme.getTheme(Brightness.dark, brandingState.brandColorHex),
                  theme: AppTheme.getTheme(Brightness.light, brandingState.brandColorHex),
                  themeMode: themeState,
                  builder: (context, child) => GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: child,
                  ),
                  home: const SplashScreen(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
