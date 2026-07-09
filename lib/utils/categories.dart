import 'package:flutter/material.dart';

// Single source of truth for the opportunity categories used across the
// app: the category filter chips on the Student Home/Search tabs, the
// category picker in the Post/Edit Opportunity form, and the icon shown
// on each "Your Opportunities" card. Keeping this list in one place means
// adding a new category later only requires one edit here, instead of
// hunting through every screen that mentions categories.
class OpportunityCategory {
  final String label;
  final IconData icon;
  const OpportunityCategory(this.label, this.icon);
}

const List<OpportunityCategory> opportunityCategories = [
  OpportunityCategory('Development', Icons.code),
  OpportunityCategory('Design', Icons.edit_outlined),
  OpportunityCategory('Marketing', Icons.trending_up),
  OpportunityCategory('Business', Icons.business_center_outlined),
];

// Looks up the icon for a given category label (e.g. 'Design' -> the
// pencil icon). Falls back to a generic briefcase icon if a category
// somehow doesn't match anything in the list above - this should only
// happen defensively, since the post/edit form only lets a startup choose
// from opportunityCategories in the first place.
IconData iconForCategory(String category) {
  for (final c in opportunityCategories) {
    if (c.label == category) return c.icon;
  }
  return Icons.work_outline;
}
