import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unihub/features/auth/models/user_profile_model.dart';

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User not authenticated');
    return uid;
  }

  Future<void> createUserProfile({
    required String email,
    required String name,
    String? phoneNumber,
    String? college,
    String? year,
    String? course,
    String? photoUrl,
  }) async {
    final userData = {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber ?? '',
      'college': college ?? '',
      'year': year ?? '',
      'course': course ?? '',
      'photoUrl': photoUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(_userId)
        .set(userData, SetOptions(merge: true));
  }

  Future<UserProfileModel?> getUserProfile() async {
    final doc = await _firestore.collection('users').doc(_userId).get();
    if (!doc.exists) return null;
    return UserProfileModel.fromFirestore(doc);
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(_userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
