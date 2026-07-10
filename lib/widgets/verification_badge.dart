import 'package:flutter/material.dart';

// A small "Verified" / "Verification pending" badge, shown anywhere a
// startup's verification status needs to appear (the Home tab's header,
// and the Profile tab). Written once so both places always agree on the
// exact wording, colors, and icon used.
class VerificationBadge extends StatelessWidget {
  final bool isVerified;

  const VerificationBadge({super.key, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? Colors.green : Colors.orange;
    final icon = isVerified ? Icons.verified : Icons.hourglass_top;
    final label = isVerified ? 'Verified ALU Startup' : 'Verification pending';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
