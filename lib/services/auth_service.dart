import 'package:firebase_auth/firebase_auth.dart';

// AuthService is a small wrapper around FirebaseAuth.
//
// Why wrap it instead of calling FirebaseAuth.instance directly from our
// screens? Two reasons:
//   1. If Firebase ever changes its API, we only need to update this one
//      file instead of every screen in the app.
//   2. It makes our code easier to read and explain in the demo: screens
//      just call `authService.signIn(...)` instead of dealing with
//      FirebaseAuth's lower level details directly.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// A live stream of the current user. Emits `null` when logged out and
  /// a `User` object when logged in. Firebase automatically keeps this in
  /// sync across app restarts (the session is persisted on the device).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// The currently logged-in Firebase user (or null if nobody is logged in).
  User? get currentUser => _firebaseAuth.currentUser;

  /// Creates a brand new account with email + password.
  /// Returns the newly created Firebase [User] on success.
  /// Throws a [FirebaseAuthException] on failure (e.g. email already used,
  /// weak password, invalid email) which the calling screen will catch and
  /// show as a friendly error message.
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  /// Logs an existing user in with email + password.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  /// Logs the current user out.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Converts Firebase's error codes into short, student-friendly messages.
  /// FirebaseAuthException.code is a machine-readable string like
  /// "email-already-in-use" - this turns it into something we can show
  /// directly in a SnackBar or under a text field.
  String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Please use a stronger password (at least 6 characters).';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
