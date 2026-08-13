import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/menu_profile_model.dart';

abstract class MenuProfileState extends Equatable {
  const MenuProfileState();
  @override
  List<Object?> get props => [];
}

class MenuProfileLoading extends MenuProfileState {}

class MenuProfilesLoaded extends MenuProfileState {
  final List<MenuProfileModel> profiles;
  const MenuProfilesLoaded({required this.profiles});
  @override
  List<Object?> get props => [profiles];
}

class MenuProfileError extends MenuProfileState {
  final String message;
  const MenuProfileError({required this.message});
  @override
  List<Object?> get props => [message];
}
