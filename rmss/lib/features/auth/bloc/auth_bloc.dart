import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/models/user_model.dart';
import 'package:rmss/features/auth/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final User? firebaseUser = await authRepository.login(
          email: event.email,
          password: event.password,
        );

        if (firebaseUser != null) {
          UserModel? userModel = await authRepository.getUserData(
            firebaseUser.uid,
          );

          if (userModel != null) {
            emit(AuthSuccess(user: userModel));
          } else {
            emit(AuthError(message: "User data not found in database"));
          }
        }
      } on FirebaseAuthException catch (e) {
        emit(
          AuthError(
            message: e.message ?? 'An unknown authentication error occurred',
          ),
        );
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        User? firebaseUser = await authRepository.signUp(
          name: event.name,
          email: event.email,
          phoneNumber: event.phoneNumber,
          address: event.address,
          password: event.password,
          photoUrl: event.photoUrl,
        );

        if (firebaseUser != null) {
          UserModel? userModel = await authRepository.getUserData(
            firebaseUser.uid,
          );
          if (userModel != null) {
            emit(AuthSuccess(user: userModel));
          } else {
            emit(AuthError(message: "User not Found in database"));
          }
        }
      } on FirebaseAuthException catch (e) {
        emit(
          AuthError(
            message: e.message ?? 'An unknown authentication error occurred',
          ),
        );
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.logout();
        emit(AuthUnauthenticated());
      } on FirebaseAuthException catch (e) {
        emit(
          AuthError(
            message: e.message ?? 'An unknown authentication error occurred',
          ),
        );
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<CheckAuthStatus>((event, emit) async {
      User? firebaseUser = authRepository.getCurrentUser();

      if (firebaseUser != null) {
        UserModel? userModel = await authRepository.getUserData(
          firebaseUser.uid,
        );

        if (userModel != null) {
          emit(AuthSuccess(user: userModel));
        } else {
          emit(AuthError(message: "User not found in database"));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.sendPasswordResetEmail(email: event.email);
        emit(AuthPasswordResetSent());
      } on FirebaseAuthException catch (e) {
        emit(AuthError(message: e.message ?? "Error"));
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });
  }
}
