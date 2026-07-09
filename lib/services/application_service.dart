import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/application.dart';
import '../models/opportunity.dart';

// Every read/write for the "applications" collection lives here, same
// pattern as OpportunityService and FirestoreService.
class ApplicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _db.collection('applications');

  // Always the same for a given (opportunity, student) pair. This is what
  // makes it impossible for a student to apply twice to the same
  // opportunity - trying again just overwrites the same document instead
  // of creating a second one.
  String _applicationId(String opportunityId, String studentId) =>
      '${opportunityId}_$studentId';

  // Applies to an opportunity. This writes to TWO documents at once:
  //   1. A new "applications" document recording the application.
  //   2. The opportunity's `applicantCount` field, bumped up by 1.
  // We use a WriteBatch so both changes succeed or fail together - we never
  // want a state where the application was recorded but the count wasn't
  // updated (or the other way around).
  Future<void> apply({
    required Opportunity opportunity,
    required String studentId,
    required String studentName,
    required String studentEmail,
  }) async {
    final applicationId = _applicationId(opportunity.id, studentId);
    final batch = _db.batch();

    batch.set(_applications.doc(applicationId), {
      'opportunityId': opportunity.id,
      'opportunityTitle': opportunity.title,
      'startupId': opportunity.startupId,
      'startupName': opportunity.startupName,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'status': ApplicationStatus.underReview,
      'appliedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_db.collection('opportunities').doc(opportunity.id), {
      // FieldValue.increment is atomic on Firestore's side - safe even if
      // many students apply to the same opportunity at the same moment.
      'applicantCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // Withdraws (deletes) an application, and brings the opportunity's
  // applicantCount back down to match - same batch-write reasoning as
  // above.
  Future<void> withdraw(Application application) async {
    final batch = _db.batch();

    batch.delete(_applications.doc(application.id));
    batch.update(
      _db.collection('opportunities').doc(application.opportunityId),
      {'applicantCount': FieldValue.increment(-1)},
    );

    await batch.commit();
  }

  // Live (real-time) look at whether this student has applied to this
  // specific opportunity, and what status it's currently at. Used on the
  // Opportunity Detail screen so that if a startup accepts/rejects the
  // application while the student happens to be looking at that screen,
  // it updates instantly - no manual refresh needed.
  Stream<Application?> streamApplication(String opportunityId, String studentId) {
    final docRef = _applications.doc(_applicationId(opportunityId, studentId));
    return docRef.snapshots().map((doc) {
      if (!doc.exists) return null;
      return Application.fromDoc(doc);
    });
  }

  // Live list of every application this student has submitted, used on the
  // "My Applications" tab. Sorted client-side by most-recent-first instead
  // of using Firestore's `.orderBy()` alongside `.where()` - same reasoning
  // as OpportunityService: combining them would require manually creating
  // a composite index in the Firebase console, an easy-to-forget setup step
  // that would break the app for anyone running it fresh.
  Stream<List<Application>> streamByStudent(String studentId) {
    return _applications
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      final applications = snapshot.docs.map(Application.fromDoc).toList();
      applications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return applications;
    });
  }

  // Live list of every application submitted to ANY of this startup's
  // opportunities, used on the "View Applicants" tab. The screen groups
  // these client-side by opportunityId to show one section per posting.
  // Same client-side-sort reasoning as streamByStudent above.
  Stream<List<Application>> streamByStartup(String startupId) {
    return _applications
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snapshot) {
      final applications = snapshot.docs.map(Application.fromDoc).toList();
      applications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return applications;
    });
  }

  // Accepts or rejects an application (or flips it back to under_review,
  // in principle) - called from the "View Applicants" tab. Deliberately
  // left reversible: a startup can change their mind and call this again
  // with a different status later, e.g. if they accidentally rejected the
  // wrong applicant.
  Future<void> updateStatus(Application application, String newStatus) async {
    await _applications.doc(application.id).update({'status': newStatus});
  }
}
