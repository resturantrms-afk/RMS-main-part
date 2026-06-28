import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/table_model.dart';

class NavigationState extends Equatable {
  final int selectedIndex;
  final TableModel? preSelectedTable;
  const NavigationState({this.selectedIndex = 0, this.preSelectedTable});

  NavigationState copyWith({
    int? selectedIndex,
    TableModel? preSelectedTable,
    bool clearTable = false,
  }) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      preSelectedTable: clearTable
          ? null
          : (preSelectedTable ?? this.preSelectedTable),
    );
  }

  @override
  List<Object?> get props => [selectedIndex, preSelectedTable];
}
