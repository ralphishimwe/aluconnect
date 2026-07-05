import 'package:flutter/material.dart';

// Represents one opportunity that a Startup has posted, as shown on the
// Startup's own "Your Opportunities" list (this is different from
// OpportunityModel, which is what Students see when browsing/searching -
// that one shows the company name, this one doesn't need to since the
// startup already knows it's their own posting).
//
// NOTE: Just like OpportunityModel, this is temporary. Once the
// "Opportunity CRUD" development step is built, this will be replaced by
// real documents read from Firestore's "opportunities" collection
// (filtered to the ones this startup posted), instead of mock data - see
// lib/data/mock_posted_opportunities.dart.
class PostedOpportunityModel {
  final String id;
  final String title;
  final IconData icon;
  final bool isActive; // false would mean the posting has been closed
  final int applicantCount;
  final String postedAgo; // e.g. "2d ago"
  final String location; // e.g. Remote, On-site
  final String workType; // e.g. Full-time, Part-time

  const PostedOpportunityModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.applicantCount,
    required this.postedAgo,
    required this.location,
    required this.workType,
    this.isActive = true,
  });
}
