import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/student_model.dart';
import '../models/startup_model.dart';

// FirestoreService centralizes every read/write to our Cloud Firestore
// database. Keeping all database calls in one file (instead of scattering
// `FirebaseFirestore.instance...` across every screen) makes the collection
// names/structure easy to find, change, and explain during the demo.
//
// Firestore collections used by this app so far:
//   users     -> { uid, email, role }            (one doc per account)
//   students  -> full StudentModel profile        (doc id == uid)
//   startups  -> full StartupModel profile        (doc id == uid)
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---- "users" collection: quick role lookup ----

  /// Saves a small "who is this account" record right after sign up.
  /// We keep this separate from the full profile so that logging in only
  /// needs one cheap read to know which Home screen to show.
  Future<void> saveAppUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  /// Fetches the small account record for a given uid. Returns null if it
  /// doesn't exist (shouldn't normally happen, but we handle it safely).
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

  /// Live (real-time) version of getStudentProfile, used on the Profile
  /// tab. This is what lets the Profile tab automatically show updated
  /// info right after saving an edit, with no manual refresh code needed -
  /// Firestore pushes the new document here the moment the write completes.
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
