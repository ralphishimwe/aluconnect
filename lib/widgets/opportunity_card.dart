import 'package:flutter/material.dart';
import '../models/opportunity_model.dart';

// A single opportunity listing card, used in the "Featured Opportunities"
// list on the Home screen and (later) in the full Search/Discovery screen.
// Kept as its own widget so we only have to build this UI once.
class OpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback? onTap;

  const OpportunityCard({super.key, required this.opportunity, this.onTap});

  @override
  Widget build(BuildContext context) {
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
              // Colored initials avatar, standing in for a company logo.
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: opportunity.avatarColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  opportunity.companyInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      opportunity.companyName,
                      style: TextStyle(color: Colors.grey.shade600),
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
                          icon: Icons.work_outline,
                          label: opportunity.category,
                        ),
                        const Spacer(),
                        Text(
                          opportunity.postedAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
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

// Small icon + label pair used for the location/category row under each
// opportunity's title (e.g. a pin icon next to "Remote").
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
