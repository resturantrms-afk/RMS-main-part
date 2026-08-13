import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/menu_profile_model.dart';
import 'package:rmss/core/models/menu_item_model.dart';

abstract class MenuProfileEvent extends Equatable {
  const MenuProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadMenuProfiles extends MenuProfileEvent {}

class UpdateMenuProfilesList extends MenuProfileEvent {
  final List<MenuProfileModel> profiles;
  const UpdateMenuProfilesList(this.profiles);
  @override
  List<Object?> get props => [profiles];
}

class AddMenuProfile extends MenuProfileEvent {
  final MenuProfileModel profile;
  const AddMenuProfile({required this.profile});
  @override
  List<Object?> get props => [profile];
}

class UpdateMenuProfile extends MenuProfileEvent {
  final MenuProfileModel profile;
  const UpdateMenuProfile({required this.profile});
  @override
  List<Object?> get props => [profile];
}

class DeleteMenuProfile extends MenuProfileEvent {
  final MenuProfileModel profile;
  const DeleteMenuProfile({required this.profile});
  @override
  List<Object?> get props => [profile];
}

class ToggleMenuProfileActiveStatus extends MenuProfileEvent {
  final MenuProfileModel profile;
  final bool isActive;
  final List<MenuItemModel> allCurrentMenuItems;

  const ToggleMenuProfileActiveStatus({
    required this.profile,
    required this.isActive,
    required this.allCurrentMenuItems,
  });
  
  @override
  List<Object?> get props => [profile, isActive, allCurrentMenuItems];
}
