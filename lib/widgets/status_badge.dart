import 'package:flutter/material.dart';
import '../models/application.dart';
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color background;
    late final Color textColor;

    if (status == ApplicationStatus.accepted) {
      label = 'Accepted';
      background = Colors.green.shade50;
      textColor = Colors.green.shade700;
    } else if (status == ApplicationStatus.rejected) {
      label = 'Rejected';
      background = Colors.red.shade50;
      textColor = Colors.red.shade700;
    } else {
      label = 'Under review';
      background = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
