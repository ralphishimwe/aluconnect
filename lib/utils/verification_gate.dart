import 'package:flutter/material.dart';
import '../models/startup_model.dart';

void requireVerifiedStartup(
  BuildContext context,
  StartupModel? profile,
  VoidCallback onVerified,
) {
  if (profile == null) return;

  if (profile.isVerified) {
    onVerified();
    return;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Verification pending'),
      content: const Text(
        'Your startup must be verified by an ALU admin before you can post '
        "opportunities. You'll be able to post as soon as your ALU "
        'affiliation is confirmed.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}
