import 'package:flutter/material.dart';

import '../../../data/mock_opportunities.dart';
import '../../../models/opportunity_model.dart';
import '../../../widgets/opportunity_card.dart';
import '../../../widgets/search_bar_field.dart';

// The "Search" tab a Student sees when they tap the Search icon in the
// bottom nav (or tap "See all" next to Featured Opportunities on Home).
//
// It shows the same search bar style as the Home screen, and the same
// opportunity card layout - but here, typing actually filters the list
// live as you type, matching against both the opportunity title and the
// company name (case-insensitive).
//
// Like the Home tab, this still reads from mockOpportunities (see
// lib/data/mock_opportunities.dart) - it will be swapped for real Firestore
// data in the "Opportunity CRUD" development step.
class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();

  // What the student has typed so far, lower-cased once here so we don't
  // repeat `.toLowerCase()` for every opportunity every time we filter.
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value.trim().toLowerCase());
  }

  // Returns every opportunity whose title or company name contains the
  // current search query. An empty query matches everything.
  List<OpportunityModel> get _results {
    if (_query.isEmpty) return mockOpportunities;

    return mockOpportunities.where((opportunity) {
      final title = opportunity.title.toLowerCase();
      final company = opportunity.companyName.toLowerCase();
      return title.contains(_query) || company.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SearchBarField(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: results.isEmpty
                  ? const _NoResultsMessage()
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return OpportunityCard(opportunity: results[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shown when the search query doesn't match any opportunity. Centered so
// it reads clearly instead of sitting awkwardly at the top of an empty list.
class _NoResultsMessage extends StatelessWidget {
  const _NoResultsMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No opportunities Found',
        style: TextStyle(color: Colors.grey, fontSize: 15),
      ),
    );
  }
}
