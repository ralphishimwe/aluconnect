import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../home/student_home_screen.dart';
import '../home/startup_home_screen.dart';
import 'login_screen.dart';

// AuthWrapper is the "traffic controller" of the app.
//
// It watches AuthProvider and decides which screen to show:
//   - unknown          -> a loading spinner (we're still checking whether
//                          a session is already saved on the device)
//   - unauthenticated  -> LoginScreen
//   - authenticated    -> StudentHomeScreen or StartupHomeScreen, depending
//                          on the logged-in user's role
//
// Because this widget *watches* AuthProvider, every part of the app reacts
// automatically the moment someone logs in, registers, or logs out -
// nobody has to manually call Navigator.push/pop when auth state changes.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    switch (authProvider.authStatus) {
      case AuthStatus.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        final role = authProvider.appUser?.role;
        if (role == UserRole.startup) {
          return const StartupHomeScreen();
        }
        return const StudentHomeScreen();
    }
  }
}
