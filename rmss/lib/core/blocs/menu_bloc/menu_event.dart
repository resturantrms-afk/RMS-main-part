import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/menu_item_model.dart';

abstract class MenuEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMenu extends MenuEvent {}

class AddMenuItem extends MenuEvent {
  final MenuItemModel item;
  AddMenuItem({required this.item});

  @override
  List<Object?> get props => [item];
}

class UpdateMenuItem extends MenuEvent {
  final MenuItemModel item;
  UpdateMenuItem({required this.item});

  @override
  List<Object?> get props => [item];
}

class DeleteMenuItem extends MenuEvent {
  final MenuItemModel item;
  DeleteMenuItem({required this.item});

  @override
  List<Object?> get props => [item];
}
