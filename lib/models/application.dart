import 'package:cloud_firestore/cloud_firestore.dart';

// The three states an application can be in. Kept as plain string
// constants (not a Dart `enum`) because these are exactly the strings we
// store in Firestore's `status` field - no extra to-string/from-string
// conversion code needed anywhere.
class ApplicationStatus {
  static const underReview = 'under_review';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
}

// Represents one student's application to one opportunity, stored in
// Firestore under the top-level "applications" collection.
//
// IMPORTANT: the document ID is always "{opportunityId}_{studentId}" (see
// ApplicationService._applicationId) instead of a random auto-generated ID.
// This guarantees a student can only ever have ONE application per
// opportunity - applying again just overwrites the same document instead of
// creating a duplicate.
//
// A few fields (opportunityTitle, startupName, studentName) are copies of
// data that also lives elsewhere (on the Opportunity/Student documents).
// This is deliberate denormalization, the same pattern already used by
// Opportunity.startupName: it lets the "My Applications" list and the
// future "View Applicants" list render instantly from one query, without
// needing a separate lookup per row.
class Application {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentId;
  final String studentName;
  final String status;
  final DateTime appliedAt;

  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.appliedAt,
    this.status = ApplicationStatus.underReview,
  });

  factory Application.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Application(
      id: doc.id,
      opportunityId: data['opportunityId'] as String? ?? '',
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      status: data['status'] as String? ?? ApplicationStatus.underReview,
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
