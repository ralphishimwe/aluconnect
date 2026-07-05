import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// A reusable "Section title ............... See all" row, used above the
// Categories and Featured Opportunities lists on the Home screen (and
// probably future sections too, like "My Applications").
//
// The "See all" link only appears when a section actually has somewhere to
// send the user (via [onSeeAll]). Categories doesn't need one - all
// categories are already visible in their scrollable row - so we simply
// don't pass a callback there and the link disappears.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Only render the "See all" link when there's an action for it to
        // perform - otherwise it would be a dead-looking button.
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'See all',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
