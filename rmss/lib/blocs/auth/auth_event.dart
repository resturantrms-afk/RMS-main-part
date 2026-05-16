import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String password;
  final String photoUrl;
  final String deviceToken;

  SignUpRequested({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.password,
    required this.photoUrl,
    required this.deviceToken,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    phoneNumber,
    address,
    password,
    photoUrl,
    deviceToken,
  ];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
