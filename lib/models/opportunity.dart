import 'package:cloud_firestore/cloud_firestore.dart';

class Opportunity {
  final String id; // Firestore document id
  final String startupId; // uid of the startup that posted this
  final String startupName; // saved alongside the posting so student-facing
  // cards don't need a second database read just to show who posted it
  final String title;
  final String category; // one of opportunityCategories, see utils/categories.dart
  final String location; // "Remote" or "On-site"
  final String workType; // "Full-time" or "Part-time"
  final String description; // optional - what the role actually involves
  final List<String> requiredSkills; // optional - e.g. ["Flutter", "Figma"]
  final bool isActive; // false once the startup closes this posting
  final int applicantCount; // how many students have applied so far
  final DateTime createdAt;

  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.category,
    required this.location,
    required this.workType,
    required this.createdAt,
    this.description = '',
    this.requiredSkills = const [],
    this.isActive = true,
    this.applicantCount = 0,
  });
  factory Opportunity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Opportunity(
      id: doc.id,
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      category: data['category'] as String? ?? '',
      location: data['location'] as String? ?? '',
      workType: data['workType'] as String? ?? '',
      description: data['description'] as String? ?? '',
      requiredSkills: List<String>.from(data['requiredSkills'] as List? ?? []),
      isActive: data['isActive'] as bool? ?? true,
      applicantCount: (data['applicantCount'] as num?)?.toInt() ?? 0,

      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
