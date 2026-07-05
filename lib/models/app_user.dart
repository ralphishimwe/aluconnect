// This file defines the "role" of a logged-in user and a small class that
// represents them. We keep this separate from the full Student/Startup
// profile models because the app often just needs to know:
//   "who is logged in, and are they a student or a startup?"
// before it decides which Home screen or which Firestore collection to use.

/// The two account types supported by ALUConnect.
///
/// We store this as a plain string ("student" / "startup") inside Firestore
/// so it is easy to read and debug directly in the Firebase console.
enum UserRole { student, startup }

/// Helper functions to convert between the [UserRole] enum and the plain
/// string we save in Firestore. Keeping this logic in one place avoids
/// typos like "Student" vs "student" spreading across the codebase.
UserRole userRoleFromString(String value) {
  switch (value) {
    case 'startup':
      return UserRole.startup;
    case 'student':
    default:
      return UserRole.student;
  }
}

String userRoleToString(UserRole role) {
  return role == UserRole.startup ? 'startup' : 'student';
}

/// A minimal representation of the currently logged-in account.
///
/// This is intentionally small. Once we know the [uid] and [role] we can
/// fetch the full Student or Startup profile document from Firestore
/// whenever a screen needs the rest of the details.
class AppUser {
  final String uid;
  final String email;
  final UserRole role;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
  });

  /// Builds an AppUser from a Firestore document snapshot's data map.
  /// Example document (in the "users" collection):
  /// { "uid": "abc123", "email": "jane@alustudent.com", "role": "student" }
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      email: map['email'] as String,
      role: userRoleFromString(map['role'] as String),
    );
  }

  /// Converts this object into a plain map so it can be saved to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': userRoleToString(role),
    };
  }
}
