enum UserRole { student, startup }

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

class AppUser {
  final String uid;
  final String email;
  final UserRole role;

  AppUser({required this.uid, required this.email, required this.role});
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      email: map['email'] as String,
      role: userRoleFromString(map['role'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'role': userRoleToString(role)};
  }
}
