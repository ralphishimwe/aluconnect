import 'package:cloud_firestore/cloud_firestore.dart';

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
