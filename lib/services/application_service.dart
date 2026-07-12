import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/application.dart';
import '../models/opportunity.dart';

class ApplicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _db.collection('applications');

  String _applicationId(String opportunityId, String studentId) =>
      '${opportunityId}_$studentId';

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
      'applicantCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> withdraw(Application application) async {
    final batch = _db.batch();

    batch.delete(_applications.doc(application.id));
    batch.update(
      _db.collection('opportunities').doc(application.opportunityId),
      {'applicantCount': FieldValue.increment(-1)},
    );

    await batch.commit();
  }

  Stream<Application?> streamApplication(
    String opportunityId,
    String studentId,
  ) {
    final docRef = _applications.doc(_applicationId(opportunityId, studentId));
    return docRef.snapshots().map((doc) {
      if (!doc.exists) return null;
      return Application.fromDoc(doc);
    });
  }

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

  Future<void> updateStatus(Application application, String newStatus) async {
    await _applications.doc(application.id).update({'status': newStatus});
  }
}
