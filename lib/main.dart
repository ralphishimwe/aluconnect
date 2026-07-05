import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_wrapper.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // AuthWrapper decides whether to show Login or the correct
        // role-based Home screen, based on the live AuthProvider state.
        home: const AuthWrapper(),
      ),
    );
  }
}
