import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String college;
  final String year;
  final String course;
  final String photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber = '',
    this.college = '',
    this.year = '',
    this.course = '',
    this.photoUrl = '',
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    return UserProfileModel(
      id: doc.id,
      email: data?['email'] ?? '',
      name: data?['name'] ?? '',
      phoneNumber: data?['phoneNumber'] ?? '',
      college: data?['college'] ?? '',
      year: data?['year'] ?? '',
      course: data?['course'] ?? '',
      photoUrl: data?['photoUrl'] ?? '',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data?['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'college': college,
      'year': year,
      'course': course,
      'photoUrl': photoUrl,
    };
  }
}
