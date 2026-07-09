import 'package:flutter/material.dart';
import '../models/application.dart';
import '../utils/time_ago.dart';

// One applicant's row on the startup's "View Applicants" tab: name, email,
// how long ago they applied, and Accept/Reject buttons.
//
// The decision is reversible (per the user's choice for this feature): both
// buttons stay active no matter the current status, so a startup can change
// their mind later. Whichever action matches the CURRENT status is shown
// filled-in/solid; the other stays as an outline - a quick visual cue for
// "this is the decision that's currently in effect" without hiding the
// option to flip it.
class ApplicantRow extends StatelessWidget {
  final Application application;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const ApplicantRow({
    super.key,
    required this.application,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = application.status == ApplicationStatus.accepted;
    final isRejected = application.status == ApplicationStatus.rejected;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              application.studentName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              application.studentEmail,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Text(
              'Applied ${timeAgo(application.appliedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DecisionButton(
                    label: 'Accept',
                    color: Colors.green,
                    isActive: isAccepted,
                    onPressed: onAccept,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DecisionButton(
                    label: 'Reject',
                    color: Colors.red,
                    isActive: isRejected,
                    onPressed: onReject,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A small Accept/Reject button that switches between a solid, filled look
// (when it's the currently active decision) and an outlined look
// (otherwise) - both states remain tappable either way.
class _DecisionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onPressed;

  const _DecisionButton({
    required this.label,
    required this.color,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}
