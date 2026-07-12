import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/student_model.dart';
import '../models/startup_model.dart';
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveAppUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }
  Future<AppUser?> getAppUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }

  // ---- "students" collection ----

  Future<void> saveStudentProfile(StudentModel student) async {
    await _db.collection('students').doc(student.uid).set(student.toMap());
  }

  Future<StudentModel?> getStudentProfile(String uid) async {
    final doc = await _db.collection('students').doc(uid).get();
    if (!doc.exists) return null;
    return StudentModel.fromMap(doc.data()!);
  }

  Stream<StudentModel?> streamStudentProfile(String uid) {
    return _db.collection('students').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return StudentModel.fromMap(doc.data()!);
    });
  }

  // ---- "startups" collection ----

  Future<void> saveStartupProfile(StartupModel startup) async {
    await _db.collection('startups').doc(startup.uid).set(startup.toMap());
  }

  Future<StartupModel?> getStartupProfile(String uid) async {
    final doc = await _db.collection('startups').doc(uid).get();
    if (!doc.exists) return null;
    return StartupModel.fromMap(doc.data()!);
  }

  /// Live version of getStartupProfile - same reasoning as
  /// streamStudentProfile above.
  Stream<StartupModel?> streamStartupProfile(String uid) {
    return _db.collection('startups').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return StartupModel.fromMap(doc.data()!);
    });
  }
}
