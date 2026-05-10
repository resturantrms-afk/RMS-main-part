import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final User? user = await authRepository.login(
          email: event.email,
          password: event.password,
        );

        if (user != null) {
          emit(AuthSuccess(user: user));
        }
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        User? user = await authRepository.signUp(
          name: event.name,
          email: event.email,
          phoneNumber: event.phoneNumber,
          address: event.address,
          password: event.password,
          photoUrl: event.photoUrl,
          deviceToken: event.deviceToken,
        );

        if (user != null) {
          emit(AuthSuccess(user: user));
        }
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.logout();
        emit(AuthInitial());
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });
  }
}
