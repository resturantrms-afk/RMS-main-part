import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/user_model.dart';

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

  SignUpRequested({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.password,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    phoneNumber,
    address,
    password,
    photoUrl,
  ];
}

class LogoutRequested extends AuthEvent {}

class ProfileUpdateRequested extends AuthEvent {
  final UserModel user;

  ProfileUpdateRequested({required this.user});

  @override
  List<Object?> get props => [user];
}

class CheckAuthStatus extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class UpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? photoUrl;
  final bool? pushNotificationsEnabled;
  final bool? pushCleaningAlertsEnabled;
  final String? paymentPin;

  UpdateProfileRequested({
    this.name, 
    this.photoUrl, 
    this.pushNotificationsEnabled,
    this.pushCleaningAlertsEnabled,
    this.paymentPin,
  });

  @override
  List<Object?> get props => [
    name, 
    photoUrl, 
    pushNotificationsEnabled, 
    pushCleaningAlertsEnabled,
    paymentPin,
  ];
}
