import 'package:cloud_firestore/cloud_firestore.dart';

// This model represents a Student's full profile.
// It is stored in Firestore under: students/{uid}
// where {uid} is the same unique ID Firebase Authentication gives the user.
// Using the auth uid as the document id makes it very easy to look up
// "the profile that belongs to whoever is logged in right now".
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

  /// Turns this object into a Map<String, dynamic> so it can be written
  /// straight into a Firestore document with `.set(student.toMap())`.
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

  /// Rebuilds a StudentModel from Firestore document data.
  /// Used whenever we read a student's profile back out of the database.
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
