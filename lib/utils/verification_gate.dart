import 'package:flutter/material.dart';
import '../models/startup_model.dart';

// Shared "verification gate" used everywhere a startup tries to post a new
// opportunity (the Home tab's "+" button and the Opportunities tab's "+"
// button both call this). Kept as one function instead of copy-pasting the
// same check in both places, so the rule ("only verified startups can
// post") only has to be written once.
//
// If the startup is verified, `onVerified` runs immediately (e.g. opens the
// post form). If not, we show an explanatory dialog instead - this is the
// "hard block" the assignment asks for: unverified startups simply cannot
// reach the post form at all, they just get told why.
void requireVerifiedStartup(
  BuildContext context,
  StartupModel? profile,
  VoidCallback onVerified,
) {
  // Profile hasn't finished loading yet - safest to do nothing rather than
  // wrongly let them through or wrongly block them.
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
