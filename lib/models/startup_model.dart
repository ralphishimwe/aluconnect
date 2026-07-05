import 'package:cloud_firestore/cloud_firestore.dart';

// This model represents a Startup/organization's full profile.
// It is stored in Firestore under: startups/{uid}
//
// NOTE on verification:
// The assignment requires that only startups genuinely recognized within
// the ALU ecosystem should be able to use the platform. Rather than
// blocking sign-up entirely (which would need a manual approval process
// before anyone could even try the app), we let a startup register and
// fill in an "ALU affiliation proof" field (e.g. their ALU Innovation Hub
// registration number, or the name of the ALU staff/program sponsoring
// them). Every new startup starts with `isVerified = false`.
//
// In a later step (Opportunity CRUD) we will only allow a startup to post
// opportunities once `isVerified` is true. For this assignment, an admin
// (you, acting as the platform owner) can flip that flag to `true` directly
// in the Firebase console after checking the affiliation proof. This keeps
// the workflow realistic without requiring us to build a full admin panel
// this early in the project.
class StartupModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String industry; // e.g. "EdTech", "Agriculture", "Fintech"
  final String description; // what the startup does
  final String aluAffiliationProof; // how they're recognized at ALU
  final bool isVerified;
  final DateTime createdAt;

  StartupModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.industry,
    required this.aluAffiliationProof,
    required this.createdAt,
    this.description = '',
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'industry': industry,
      'description': description,
      'aluAffiliationProof': aluAffiliationProof,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory StartupModel.fromMap(Map<String, dynamic> map) {
    return StartupModel(
      uid: map['uid'] as String,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      industry: map['industry'] as String? ?? '',
      description: map['description'] as String? ?? '',
      aluAffiliationProof: map['aluAffiliationProof'] as String? ?? '',
      isVerified: map['isVerified'] as bool? ?? false,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
