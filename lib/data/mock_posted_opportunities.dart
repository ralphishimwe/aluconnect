import 'package:flutter/material.dart';
import '../models/posted_opportunity_model.dart';

// TEMPORARY placeholder data for the Startup Home screen's "Your
// Opportunities" list. This entire file will be deleted once the
// "Opportunity CRUD" development step wires the Startup Home screen up to
// this startup's real postings from Firestore instead.
final List<PostedOpportunityModel> mockPostedOpportunities = [
  const PostedOpportunityModel(
    id: '1',
    title: 'Mobile App Developer Intern',
    icon: Icons.work_outline,
    applicantCount: 12,
    postedAgo: '2d ago',
    location: 'Remote',
    workType: 'Full-time',
  ),
  const PostedOpportunityModel(
    id: '2',
    title: 'UI/UX Design Intern',
    icon: Icons.campaign_outlined,
    applicantCount: 8,
    postedAgo: '5d ago',
    location: 'On-site',
    workType: 'Part-time',
  ),
  const PostedOpportunityModel(
    id: '3',
    title: 'Marketing & Content Intern',
    icon: Icons.bar_chart,
    applicantCount: 5,
    postedAgo: '7d ago',
    location: 'Remote',
    workType: 'Part-time',
  ),
];
