import 'package:flutter/material.dart';

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
