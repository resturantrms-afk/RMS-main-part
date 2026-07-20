import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/user_model.dart';

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllUsers extends AdminUsersEvent {}

class UpdateUserRole extends AdminUsersEvent {
  final String userId;
  final UserRoles newRole;

  const UpdateUserRole({required this.userId, required this.newRole});

  @override
  List<Object?> get props => [userId, newRole];
}

class UpdateUser extends AdminUsersEvent {
  final UserModel user;

  const UpdateUser({required this.user});

  @override
  List<Object?> get props => [user];
}

class DeleteUser extends AdminUsersEvent {
  final String userId;

  const DeleteUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddUser extends AdminUsersEvent {
  final Map<String, dynamic> userData;
  final String password;

  const AddUser({required this.userData, required this.password});

  @override
  List<Object?> get props => [userData, password];
}
