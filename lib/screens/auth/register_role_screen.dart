import 'package:flutter/material.dart';
import 'register_student_screen.dart';
import 'register_startup_screen.dart';

// Before showing a registration form, we first ask "who are you?".
// This matters because Students and Startups collect very different
// information (a program of study vs. an industry + ALU affiliation proof),
// and they end up in different Firestore collections. Splitting this into
// its own screen keeps each registration form focused and simple, which
// supports the "easily readable" goal from the project brief.
class RegisterRoleScreen extends StatelessWidget {
  const RegisterRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create an account')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'I am registering as a...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            _RoleCard(
              icon: Icons.person_outline,
              title: 'Student',
              subtitle: 'Looking for internship opportunities',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterStudentScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              icon: Icons.rocket_launch_outlined,
              title: 'Startup / Organization',
              subtitle: 'Looking to post opportunities and find talent',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterStartupScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A simple tappable card, reused for both role choices above.
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.deepPurple),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
