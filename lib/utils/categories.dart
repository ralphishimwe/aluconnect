import 'package:flutter/material.dart';

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

IconData iconForCategory(String category) {
  for (final c in opportunityCategories) {
    if (c.label == category) return c.icon;
  }
  return Icons.work_outline;
}
