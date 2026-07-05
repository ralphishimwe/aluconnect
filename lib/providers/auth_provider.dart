import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/student_model.dart';
import '../models/startup_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// AuthProvider is the heart of our state management for this project.
//
// We picked Provider (with ChangeNotifier) because:
//   - It's the officially recommended, simplest state management option
//     for Flutter, which matches the "beginner friendly, easily readable"
//     goal for this project.
//   - `notifyListeners()` gives us one clear signal: "something about the
//     logged-in user changed - please rebuild whichever widgets care".
//   - Any screen in the widget tree can read the current auth state with
//     `context.watch<AuthProvider>()` without us manually passing user data
//     down through every constructor.
//
// How it fits into the app:
//   main.dart wraps the whole app in a ChangeNotifierProvider<AuthProvider>.
//   AuthWrapper (screens/auth/auth_wrapper.dart) watches `authStatus` and
//   decides whether to show the Login screen or the correct role-based
//   Home screen. Every widget rebuild happens automatically -- no manual
//   Navigator calls needed when the login state changes.
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _authStatus = AuthStatus.unknown;
  AppUser? _appUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    // Whenever Firebase reports the user logged in or out (including on
    // app restart, since Firebase persists sessions on-device), we react
    // here and refresh our own state to match.
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // ---- Public getters used by the UI ----
  AuthStatus get authStatus => _authStatus;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _appUser = null;
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    // A Firebase user exists, so look up our own "users" record to find
    // out whether they are a student or a startup.
    final appUser = await _firestoreService.getAppUser(firebaseUser.uid);
    _appUser = appUser;
    _authStatus =
        appUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Clears any previous error message. Screens call this when the user
  /// starts typing again after seeing an error.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ---- Registration ----

  /// Registers a new Student account:
  ///   1. Creates the Firebase Auth user (email + password).
  ///   2. Saves a small "users/{uid}" record so we know their role.
  ///   3. Saves the full profile under "students/{uid}".
  /// Returns true on success, false on failure (with errorMessage set).
  Future<bool> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String program,
  }) async {
    return _runAuthAction(() async {
      final firebaseUser =
          await _authService.signUp(email: email, password: password);
      if (firebaseUser == null) return false;

      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: email.trim(),
        role: UserRole.student,
      );
      await _firestoreService.saveAppUser(appUser);

      final student = StudentModel(
        uid: firebaseUser.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        address: address.trim(),
        program: program.trim(),
        createdAt: DateTime.now(),
      );
      await _firestoreService.saveStudentProfile(student);

      _appUser = appUser;
      return true;
    });
  }

  /// Registers a new Startup account. Same three steps as above, but saves
  /// into the "startups" collection instead, and always starts out with
  /// isVerified = false (see startup_model.dart for why).
  Future<bool> registerStartup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String industry,
    required String aluAffiliationProof,
  }) async {
    return _runAuthAction(() async {
      final firebaseUser =
          await _authService.signUp(email: email, password: password);
      if (firebaseUser == null) return false;

      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: email.trim(),
        role: UserRole.startup,
      );
      await _firestoreService.saveAppUser(appUser);

      final startup = StartupModel(
        uid: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        address: address.trim(),
        industry: industry.trim(),
        aluAffiliationProof: aluAffiliationProof.trim(),
        createdAt: DateTime.now(),
      );
      await _firestoreService.saveStartupProfile(startup);

      _appUser = appUser;
      return true;
    });
  }

  // ---- Login / logout ----

  Future<bool> login({required String email, required String password}) {
    return _runAuthAction(() async {
      final firebaseUser =
          await _authService.signIn(email: email, password: password);
      if (firebaseUser == null) return false;

      final appUser = await _firestoreService.getAppUser(firebaseUser.uid);
      _appUser = appUser;
      return appUser != null;
    });
  }

  Future<void> logout() async {
    await _authService.signOut();
    _appUser = null;
    _authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Small helper that wraps every auth action with the same loading /
  /// error-handling logic so we don't repeat try/catch blocks everywhere.
  Future<bool> _runAuthAction(Future<bool> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await action();
      if (success) {
        _authStatus = AuthStatus.authenticated;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.friendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
