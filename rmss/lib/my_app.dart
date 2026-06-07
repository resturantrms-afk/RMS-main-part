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
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/repository/auth_repository.dart';
import 'package:rmss/features/auth/views/splash_screen.dart';

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
      ],
      child: MultiBlocProvider(
        providers: [
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
        ],
        child: MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          darkTheme: AppTheme.darkTheme,
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
