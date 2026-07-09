import 'package:cloud_firestore/cloud_firestore.dart';

// Represents one internship/opportunity posting, stored in Firestore under
// the top-level "opportunities" collection (see services/opportunity_service.dart).
//
// One shared collection is used by both roles instead of keeping two
// separate copies of the same data:
//   - Startups query the ones where startupId == their own uid, for
//     "Your Opportunities".
//   - Students query all active ones, for "Featured Opportunities" and
//     Search.
//
// This replaces the temporary OpportunityModel/PostedOpportunityModel and
// mock data files used earlier while we were just building the screen
// layouts - this is the real, Firestore-backed version.
class Opportunity {
  final String id; // Firestore document id
  final String startupId; // uid of the startup that posted this
  final String startupName; // saved alongside the posting so student-facing
  // cards don't need a second database read just to show who posted it
  final String title;
  final String category; // one of opportunityCategories, see utils/categories.dart
  final String location; // "Remote" or "On-site"
  final String workType; // "Full-time" or "Part-time"
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
    this.isActive = true,
    this.applicantCount = 0,
  });

  /// Builds an Opportunity straight from a Firestore document snapshot.
  /// Every field falls back to a safe default if it's somehow missing, so
  /// a malformed document can never crash the whole list.
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
      isActive: data['isActive'] as bool? ?? true,
      applicantCount: (data['applicantCount'] as num?)?.toInt() ?? 0,
      // createdAt can briefly be null right after creating a document with
      // FieldValue.serverTimestamp(), before the server confirms the write.
      // Falling back to "now" means the UI never crashes during that split
      // second.
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
