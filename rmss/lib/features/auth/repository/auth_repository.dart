import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return _firebaseAuth.currentUser;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<User?> signUp({
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    required String password,
    required String photoUrl,
  }) async {
    // create a new user
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // get the uid of the user
    String uid = _firebaseAuth.currentUser!.uid;

    // save the other data of the user
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': 'no-role',
      'photoUrl': photoUrl,
      'status': 'active',
      'createdDate':
          FieldValue.serverTimestamp(), // Firestore's way of getting the exact time
      'lastLoginDate': FieldValue.serverTimestamp(),
      'deviceToken': '',
    });

    return _firebaseAuth.currentUser;
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
