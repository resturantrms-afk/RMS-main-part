import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/menu_item_model.dart';

abstract class MenuState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<MenuItemModel> items;

  MenuLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class MenuError extends MenuState {
  final String message;
  MenuError({required this.message});

  @override
  List<Object?> get props => [message];
}
