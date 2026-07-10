import 'package:flutter/material.dart';
import '../models/application.dart';
import '../utils/avatar_style.dart';
import '../utils/time_ago.dart';
import 'status_badge.dart';

// One applicant's row inside an opportunity's list on the startup's "View
// Applicants" tab: a compact, tappable tile (avatar initials, name, applied
// time, current status, and a chevron) - tapping it opens the full
// Applicant Detail screen, which is where Accept/Reject actually live now
// (see screens/applicants/applicant_detail_screen.dart). This row itself is
// just for scanning who applied and their current status at a glance.
class ApplicantRow extends StatelessWidget {
  final Application application;
  final VoidCallback onTap;

  const ApplicantRow({
    super.key,
    required this.application,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = initialsFromName(application.studentName);
    final avatarColor = colorFromName(application.studentName);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: avatarColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.studentName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Applied ${timeAgo(application.appliedAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(status: application.status),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
