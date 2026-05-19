import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/table_model.dart';

abstract class TableEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTables extends TableEvent {}

class AddTable extends TableEvent {
  final TableModel item;
  AddTable({required this.item});

  @override
  List<Object?> get props => [item];
}

class UpdateTable extends TableEvent {
  final TableModel item;
  UpdateTable({required this.item});

  @override
  List<Object?> get props => [item];
}

class DeleteTable extends TableEvent {
  final TableModel item;
  DeleteTable({required this.item});

  @override
  List<Object?> get props => [item];
}
