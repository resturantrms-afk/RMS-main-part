import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/admin/blocs/navigation_cubit/navigation.state.dart';
import 'package:rmss/core/models/table_model.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void navigateTo(int index) {
    emit(state.copyWith(selectedIndex: index, clearTable: true));
  }

  void navigateToMenu({TableModel? preSelectedTable}) {
    emit(NavigationState(selectedIndex: 1, preSelectedTable: preSelectedTable));
  }

  void navigateToOrders() {
    emit(state.copyWith(selectedIndex: 2, clearTable: true));
  }

  void navigateToPayments() {
    emit(state.copyWith(selectedIndex: 3, clearTable: true));
  }
}
