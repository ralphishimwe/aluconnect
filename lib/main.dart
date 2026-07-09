import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'utils/app_colors.dart';

void main() async {
  // Firebase needs Flutter's engine to be ready before we can talk to it.
  WidgetsFlutterBinding.ensureInitialized();

  // Connects this app to the Firebase project you configured in the
  // Firebase console (Authentication + Firestore live there).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ALUConnectApp());
}

class ALUConnectApp extends StatelessWidget {
  const ALUConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider makes every provider listed here available to every
    // screen in the widget tree below it. We only have AuthProvider today,
    // but later steps (Opportunity CRUD, Applications) will each add their
    // own provider here - this is why Provider scales well as the app grows.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'ALUConnect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Seeding the whole theme from our one brand color (see
          // utils/app_colors.dart) keeps buttons, links, and highlights
          // visually consistent across every screen in the app.
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
          // Setting this once here (instead of on every individual AppBar)
          // means every screen with an AppBar automatically gets our brand
          // color as its background, with white text/icons on top so it
          // stays readable. If we ever change the brand color, every AppBar
          // in the app updates together.
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        // AuthWrapper decides whether to show Login or the correct
        // role-based Home screen, based on the live AuthProvider state.
        home: const AuthWrapper(),
      ),
    );
  }
}
