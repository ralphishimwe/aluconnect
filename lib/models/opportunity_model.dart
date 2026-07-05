import 'package:flutter/material.dart';

// A lightweight model for a single opportunity card shown on the Student
// Home screen (e.g. "Mobile App Developer Intern" at "TechNova").
//
// NOTE: This is intentionally simple for now. In the upcoming "Opportunity
// CRUD" development step, we will replace this with a full model that maps
// to/from a Firestore "opportunities" collection (with fromMap/toMap like
// StudentModel and StartupModel already have). For this step we're only
// focused on getting the Home screen's layout right, so the data below is
// temporary placeholder/mock data - see lib/data/mock_opportunities.dart.
class OpportunityModel {
  final String id;
  final String title;
  final String companyName;
  final String companyInitials; // shown inside the colored avatar box
  final Color avatarColor;
  final String category; // e.g. Development, Design, Marketing, Business
  final String location; // e.g. Remote, On-site
  final String postedAgo; // e.g. "2d ago"

  const OpportunityModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.companyInitials,
    required this.avatarColor,
    required this.category,
    required this.location,
    required this.postedAgo,
  });
}
