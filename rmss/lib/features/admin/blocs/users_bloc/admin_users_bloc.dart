import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/repositories/user_repository.dart';
import 'package:rmss/core/models/user_model.dart';
import 'dart:async';
import 'admin_users_event.dart';
import 'admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final UserRepository userRepository;
  StreamSubscription? _usersSubscription;
  
  AdminUsersBloc({required this.userRepository}) : super(AdminUsersInitial()) {
    on<LoadAllUsers>((event, emit) async {
      emit(AdminUsersLoading());
      await _usersSubscription?.cancel();
      _usersSubscription = userRepository.getUsersStream().listen(
        (users) {
          add(_UsersUpdated(users));
        },
        onError: (error) {
          emit(AdminUsersError(message: error.toString()));
        },
      );
    });

    on<_UsersUpdated>((event, emit) {
      emit(AdminUsersLoaded(allUsers: event.users));
    });

    on<UpdateUserRole>((event, emit) async {
      try {
        await userRepository.updateUserRole(event.userId, event.newRole.name);
      } catch (e) {
        emit(AdminUsersError(message: e.toString()));
      }
    });

    on<UpdateUser>((event, emit) async {
      try {
        await userRepository.updateUser(event.user);
      } catch (e) {
        emit(AdminUsersError(message: e.toString()));
      }
    });

    on<DeleteUser>((event, emit) async {
      try {
        await userRepository.deleteUser(event.userId);
      } catch (e) {
        emit(AdminUsersError(message: e.toString()));
      }
    });

    on<AddUser>((event, emit) async {
      try {
        final data = Map<String, dynamic>.from(event.userData);
        data['createdDate'] = Timestamp.now();
        data['lastLoginDate'] = Timestamp.now();
        data['deviceToken'] = '';
        await userRepository.addUser(data);
      } catch (e) {
        emit(AdminUsersError(message: e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }
}

class _UsersUpdated extends AdminUsersEvent {
  final List<UserModel> users;
  const _UsersUpdated(this.users);
}
