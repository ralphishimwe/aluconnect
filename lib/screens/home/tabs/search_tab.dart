import 'package:flutter/material.dart';

import '../../../models/opportunity.dart';
import '../../../services/opportunity_service.dart';
import '../../../widgets/app_top_bar.dart';
import '../../../widgets/opportunity_card.dart';
import '../../../widgets/search_bar_field.dart';
import '../../opportunities/opportunity_detail_screen.dart';

// The "Search" tab a Student sees when they tap the Search icon in the
// bottom nav (or tap "See all" next to Featured Opportunities on Home).
//
// It shows the same search bar style as the Home screen, and the same
// opportunity card layout - but here, typing actually filters the list
// live as you type, matching against both the opportunity title and the
// startup's name (case-insensitive).
//
// The list itself is live Firestore data (see OpportunityService), the
// same stream used on the Home tab - so a newly-posted opportunity shows
// up here immediately too, with no manual refresh needed.
class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  final OpportunityService _opportunityService = OpportunityService();

  // Created once, not inside build(), so we only subscribe to Firestore a
  // single time for this screen (see the same pattern used in
  // student_dashboard_tab.dart).
  late final Stream<List<Opportunity>> _opportunitiesStream =
      _opportunityService.streamActiveOpportunities();

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

  // Opens the full detail screen for an opportunity - this is where the
  // student actually applies (see opportunity_detail_screen.dart).
  void _openDetail(Opportunity opportunity) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            OpportunityDetailScreen(opportunity: opportunity),
      ),
    );
  }

  // Returns every opportunity (from the given full list) whose title or
  // startup name contains the current search query. An empty query matches
  // everything.
  List<Opportunity> _filter(List<Opportunity> opportunities) {
    if (_query.isEmpty) return opportunities;

    return opportunities.where((opportunity) {
      final title = opportunity.title.toLowerCase();
      final startupName = opportunity.startupName.toLowerCase();
      return title.contains(_query) || startupName.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Same fixed colored top bar pattern used on the Home tabs - see
    // widgets/app_top_bar.dart - so every tab looks consistent.
    return Column(
      children: [
        const AppTopBar(title: 'Search'),
        Expanded(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildResults()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return StreamBuilder<List<Opportunity>>(
      stream: _opportunitiesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Could not load opportunities. Please try again.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final results = _filter(snapshot.data ?? []);

        if (results.isEmpty) {
          return const _NoResultsMessage();
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final opportunity = results[index];
            return OpportunityCard(
              opportunity: opportunity,
              onTap: () => _openDetail(opportunity),
            );
          },
        );
      },
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
