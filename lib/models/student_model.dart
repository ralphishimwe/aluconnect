import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String program; // e.g. "BSE - Software Engineering"
  final String bio; // short "about me" section, shown to startups
  final List<String> skills; // e.g. ["Flutter", "UI Design", "Marketing"]
  final DateTime createdAt;

  StudentModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.program,
    required this.createdAt,
    this.bio = '',
    this.skills = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'program': program,
      'bio': bio,
      'skills': skills,
      // Firestore has its own Timestamp type for dates.
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      uid: map['uid'] as String,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      program: map['program'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      skills: List<String>.from(map['skills'] as List? ?? []),
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
