import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserStatus { active, inactive }

enum UserRoles { admin, cashier, kitchen, waiter, noRole }

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final UserRoles role;
  final String photoUrl;
  final UserStatus status;
  final Timestamp createdDate;
  final Timestamp lastLoginDate;
  final String deviceToken;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.role,
    required this.photoUrl,
    required this.status,
    required this.createdDate,
    required this.lastLoginDate,
    required this.deviceToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UserModel(
      id: documentId,
      name: json['name'] ?? 'invalid',
      email: json['email'] ?? 'invalid',
      phoneNumber: json['phoneNumber'] ?? 'invalid',
      address: json['address'] ?? 'invalid',
      role: UserRoles.values.firstWhere(
        (e) => e.name == (json['role'] ?? 'no-role'),
        orElse: () => UserRoles.noRole,
      ),
      photoUrl: json['photoUrl'] ?? 'invalid',
      status: UserStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'active'),
        orElse: () => UserStatus.active,
      ),
      createdDate: json['createdDate'] ?? Timestamp.now(),
      lastLoginDate: json['lastLoginDate'] ?? Timestamp.now(),
      deviceToken: json['deviceToken'] ?? 'invalid',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role.name,
      'photoUrl': photoUrl,
      'status': status.name,
      'createdDate': createdDate,
      'lastLoginDate': lastLoginDate,
      'deviceToken': deviceToken,
    };
  }

  @override
  List<Object?> get props => [];
}
