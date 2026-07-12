import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity.dart';

class OpportunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _db.collection('opportunities');

  Future<void> createOpportunity({
    required String startupId,
    required String startupName,
    required String title,
    required String category,
    required String location,
    required String workType,
    String description = '',
    List<String> requiredSkills = const [],
  }) async {
    await _opportunities.add({
      'startupId': startupId,
      'startupName': startupName,
      'title': title,
      'category': category,
      'location': location,
      'workType': workType,
      'description': description,
      'requiredSkills': requiredSkills,
      'isActive': true,
      'applicantCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOpportunity(
    String id, {
    required String title,
    required String category,
    required String location,
    required String workType,
    required bool isActive,
    String description = '',
    List<String> requiredSkills = const [],
  }) async {
    await _opportunities.doc(id).update({
      'title': title,
      'category': category,
      'location': location,
      'workType': workType,
      'description': description,
      'requiredSkills': requiredSkills,
      'isActive': isActive,
    });
  }

  Future<void> deleteOpportunity(String id) async {
    await _opportunities.doc(id).delete();
  }

  Stream<List<Opportunity>> streamByStartup(String startupId) {
    return _opportunities
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snapshot) {
          final opportunities = snapshot.docs.map(Opportunity.fromDoc).toList();
          opportunities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return opportunities;
        });
  }

  Stream<List<Opportunity>> streamActiveOpportunities() {
    return _opportunities.snapshots().map((snapshot) {
      final opportunities = snapshot.docs
          .map(Opportunity.fromDoc)
          .where((opportunity) => opportunity.isActive)
          .toList();
      opportunities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return opportunities;
    });
  }
}
