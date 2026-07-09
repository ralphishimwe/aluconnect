import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../utils/app_colors.dart';
import '../utils/categories.dart';
import '../utils/time_ago.dart';

// A single "opportunity I posted" card, shown in the "Your Opportunities"
// list on the Startup Home screen. Unlike OpportunityCard (which Students
// see), this card shows things only the poster cares about: whether the
// posting is still active, and how many students have applied.
class PostedOpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback? onTap;

  const PostedOpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Green while the posting is active, grey once it's closed.
    final statusColor = opportunity.isActive ? Colors.green : Colors.grey;
    final statusLabel = opportunity.isActive ? 'Active' : 'Closed';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored icon box standing in for a category icon (later
              // this could reflect the opportunity's category instead).
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  iconForCategory(opportunity.category),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            opportunity.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 13,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${opportunity.applicantCount} applicants',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeAgo(opportunity.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MetaTag(
                          icon: Icons.location_on_outlined,
                          label: opportunity.location,
                        ),
                        const SizedBox(width: 12),
                        _MetaTag(
                          icon: Icons.schedule,
                          label: opportunity.workType,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small icon + label pair used for the location/work-type row under each
// posting's title (mirrors the private helper in opportunity_card.dart).
class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
