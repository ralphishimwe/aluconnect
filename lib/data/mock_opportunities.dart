import 'package:flutter/material.dart';
import '../models/opportunity_model.dart';

// TEMPORARY placeholder data so the Student Home screen has something to
// display while we build its layout. This entire file will be deleted once
// the "Opportunity CRUD" development step wires the Home screen up to real
// data from Firestore's "opportunities" collection instead.
final List<OpportunityModel> mockOpportunities = [
  const OpportunityModel(
    id: '1',
    title: 'Mobile App Developer Intern',
    companyName: 'TechNova',
    companyInitials: 'TN',
    avatarColor: Color(0xFF1F2937),
    category: 'Development',
    location: 'Remote',
    postedAgo: '2d ago',
  ),
  const OpportunityModel(
    id: '2',
    title: 'UI/UX Design Intern',
    companyName: 'CreativeHub',
    companyInitials: 'CH',
    avatarColor: Color(0xFF4F46E5),
    category: 'Design',
    location: 'On-site',
    postedAgo: '3d ago',
  ),
  const OpportunityModel(
    id: '3',
    title: 'Marketing & Content Intern',
    companyName: 'GrowthCo',
    companyInitials: 'GC',
    avatarColor: Color(0xFF312E81),
    category: 'Marketing',
    location: 'Remote',
    postedAgo: '5d ago',
  ),
];
