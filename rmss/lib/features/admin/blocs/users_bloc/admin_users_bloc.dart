import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/repositories/user_repository.dart';
import 'package:rmss/core/models/user_model.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        // Create user in Firebase Auth using a secondary app instance
        // This prevents the admin from being logged out of their own account
        FirebaseApp secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}',
          options: Firebase.app().options,
        );

        UserCredential credential = await FirebaseAuth.instanceFor(app: secondaryApp)
            .createUserWithEmailAndPassword(
          email: event.userData['email'],
          password: event.password,
        );

        final uid = credential.user!.uid;

        // Clean up the secondary app instance
        await secondaryApp.delete();

        final data = Map<String, dynamic>.from(event.userData);
        data['createdDate'] = Timestamp.now();
        data['lastLoginDate'] = Timestamp.now();
        data['deviceToken'] = '';
        
        await userRepository.addUserWithId(uid, data);
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
