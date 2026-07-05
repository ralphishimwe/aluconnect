import 'package:flutter/material.dart';

// A simple "this screen isn't built yet" placeholder, used for bottom nav
// tabs (Search, Applications, Profile) that will be filled in during their
// own dedicated development steps later in the project plan. Keeping this
// as one reusable widget avoids writing the same empty-state layout three
// separate times.
class ComingSoonPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const ComingSoonPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
