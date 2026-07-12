import 'package:flutter/material.dart';
import '../models/application.dart';
import '../utils/time_ago.dart';
import 'status_badge.dart';
class ApplicationCard extends StatelessWidget {
  final Application application;



  final VoidCallback? onWithdraw;

  const ApplicationCard({
    super.key,
    required this.application,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {

    final canWithdraw =
        onWithdraw != null && application.status == ApplicationStatus.underReview;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    application.opportunityTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: application.status),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              application.startupName,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Applied ${timeAgo(application.appliedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                if (canWithdraw) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: onWithdraw,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Withdraw',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
