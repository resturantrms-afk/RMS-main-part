import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/user_model.dart';
// TODO: Import specific role models once created

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  // We can keep base users and their role-specific models here
  final List<UserModel> allUsers;
  
  const AdminUsersLoaded({required this.allUsers});

  @override
  List<Object?> get props => [allUsers];
}

class AdminUsersError extends AdminUsersState {
  final String message;

  const AdminUsersError({required this.message});

  @override
  List<Object?> get props => [message];
}
