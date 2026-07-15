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

// Add more events as needed for assigning tables, etc.
