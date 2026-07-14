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
import 'package:rmss/core/theme/colors.dart';
<<<<<<< HEAD
import 'package:rmss/features/kitchen/services/kitchen_notification_service.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/repository/auth_repository.dart';
import 'package:rmss/features/auth/screens/splash_screen.dart';
import 'package:rmss/features/kitchen/widget/kitchen_header.dart';
import 'package:rmss/features/kitchen/Screens/kitchen_main_layout.dart';
=======
import 'package:rmss/core/theme/theme_cubit.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/repository/auth_repository.dart';
import 'package:rmss/features/auth/views/splash_screen.dart';
import 'package:rmss/features/cashier/blocs/navigation_cubit/navigation_cubit.dart';
import 'package:rmss/features/cashier/repository/cashier_notification_repository.dart';
import 'package:rmss/features/cashier/blocs/notification_bloc/cashier_notification_bloc.dart';
import 'package:rmss/features/cashier/blocs/notification_bloc/cashier_notification_event.dart';
import 'package:rmss/features/waiter/repository/waiter_notification_repository.dart';
import 'package:rmss/features/waiter/blocs/notification_bloc/waiter_notification_bloc.dart';
import 'package:rmss/features/waiter/blocs/notification_bloc/waiter_notification_event.dart';
>>>>>>> aa1f94d0acbd4d5c3cbe47af019f25cc39ce403c

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
<<<<<<< HEAD
        RepositoryProvider(create: (context) => KitchenNotificationService()..startListening()),
=======
        RepositoryProvider(
          create: (context) => CashierNotificationRepository(),
        ),
        RepositoryProvider(create: (context) => WaiterNotificationRepository()),
>>>>>>> aa1f94d0acbd4d5c3cbe47af019f25cc39ce403c
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => NavigationCubit()),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
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
            create: (context) => WaiterNotificationBloc(
              repository: context.read<WaiterNotificationRepository>(),
            )..add(WaiterStartListeningNotifications()),
          ),
        ],
<<<<<<< HEAD
        child: MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          darkTheme: AppTheme.darkTheme,
          theme: AppTheme.lightTheme,
          home: const KitchenMainLayout(),
=======
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
>>>>>>> aa1f94d0acbd4d5c3cbe47af019f25cc39ce403c
        ),
      ),
    );
  }
}
