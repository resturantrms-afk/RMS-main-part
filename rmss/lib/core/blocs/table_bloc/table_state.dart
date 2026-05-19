import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/table_model.dart';

abstract class TableState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TableInitial extends TableState {}

class TablesLoading extends TableState {}

class TablesLoaded extends TableState {
  final List<TableModel> items;

  TablesLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class TableError extends TableState {
  final String message;
  TableError({required this.message});

  @override
  List<Object?> get props => [message];
}
