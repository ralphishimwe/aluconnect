import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/student_model.dart';
import '../models/startup_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _authStatus = AuthStatus.unknown;
  AppUser? _appUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

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
    final appUser = await _firestoreService.getAppUser(firebaseUser.uid);
    _appUser = appUser;
    _authStatus = appUser != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ---- Registration ----
  Future<bool> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String program,
  }) async {
    return _runAuthAction(() async {
      final firebaseUser = await _authService.signUp(
        email: email,
        password: password,
      );
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
      final firebaseUser = await _authService.signUp(
        email: email,
        password: password,
      );
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
      final firebaseUser = await _authService.signIn(
        email: email,
        password: password,
      );
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
