import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> hasProfile(String uid) async {
    final doc = await _firestore.collection('user_profiles').doc(uid).get();
    return doc.exists;
  }

  Future<void> createProfile({
    required String uid,
    required String username,
    required String? email,
  }) async {
    await _firestore.collection('user_profiles').doc(uid).set({
      'username': username,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'isHost': true,
    }, SetOptions(merge: true));
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
