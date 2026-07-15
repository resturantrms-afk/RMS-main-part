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
import 'package:rmss/core/theme/colors.dart';
import 'package:rmss/core/theme/theme_cubit.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/repository/auth_repository.dart';
import 'package:rmss/features/auth/views/splash_screen.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_bloc.dart';
import 'package:rmss/features/admin/blocs/reports_bloc/reports_bloc.dart';
import 'package:rmss/features/admin/repository/reports_repository.dart';
import 'package:rmss/features/admin/blocs/ai_bloc/ai_bloc.dart';
import 'package:rmss/features/cashier/blocs/navigation_cubit/navigation_cubit.dart';
import 'package:rmss/features/cashier/repository/cashier_notification_repository.dart';
import 'package:rmss/features/cashier/blocs/notification_bloc/cashier_notification_bloc.dart';
import 'package:rmss/features/cashier/blocs/notification_bloc/cashier_notification_event.dart';
import 'package:rmss/features/waiter/repository/waiter_notification_repository.dart';
import 'package:rmss/features/waiter/blocs/notification_bloc/waiter_notification_bloc.dart';
import 'package:rmss/features/waiter/blocs/notification_bloc/waiter_notification_event.dart';
import 'package:rmss/features/admin/blocs/navigation_cubit/navigation_cubit.dart'
    as admin_nav;
import 'package:rmss/features/admin/repository/admin_notification_repository.dart';
import 'package:rmss/features/admin/blocs/notification_bloc/admin_notification_bloc.dart';
import 'package:rmss/features/admin/blocs/notification_bloc/admin_notification_event.dart'
    as admin_notif_event;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => TableRepository()),
        RepositoryProvider(create: (context) => MenuRepository()),
        RepositoryProvider(create: (context) => OrderRepository()),
        RepositoryProvider(create: (context) => PaymentRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
        RepositoryProvider(
          create: (context) => CashierNotificationRepository(),
        ),
        RepositoryProvider(create: (context) => AdminNotificationRepository()),
        RepositoryProvider(create: (context) => WaiterNotificationRepository()),
        RepositoryProvider(create: (context) => ReportsRepository()),
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
                AdminUsersBloc(userRepository: context.read<UserRepository>()),
          ),
          BlocProvider(
            create: (context) => ReportsBloc(reportsRepository: context.read<ReportsRepository>()),
          ),
          BlocProvider(
            create: (context) => AiBloc(),
          ),
          BlocProvider(
            create: (context) =>
                MenuBloc(repository: context.read<MenuRepository>())
                  ..add(LoadMenu()),
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
            create: (context) => CashierNotificationBloc(
              repository: context.read<CashierNotificationRepository>(),
            )..add(StartListeningNotifications()),
          ),
          BlocProvider(
            create: (context) => AdminNotificationBloc(
              repository: context.read<AdminNotificationRepository>(),
            )..add(admin_notif_event.StartListeningNotifications()),
          ),
          BlocProvider(
            create: (context) => WaiterNotificationBloc(
              repository: context.read<WaiterNotificationRepository>(),
            )..add(WaiterStartListeningNotifications()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, state) {
            return MaterialApp(
              title: AppConfig.appName,
              debugShowCheckedModeBanner: false,
              darkTheme: AppTheme.darkTheme,
              theme: AppTheme.lightTheme,
              themeMode: state,
              builder: (context, child) => GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: child,
              ),
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
