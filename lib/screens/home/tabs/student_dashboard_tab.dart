import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/opportunity.dart';
import '../../../models/student_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../services/opportunity_service.dart';
import '../../../utils/categories.dart';
import '../../../widgets/app_top_bar.dart';
import '../../../widgets/category_chip.dart';
import '../../../widgets/opportunity_card.dart';
import '../../../widgets/search_bar_field.dart';
import '../../../widgets/section_header.dart';
import '../../opportunities/opportunity_detail_screen.dart';

// The "Home" tab a Student sees after logging in. This matches the sample
// UI design we were given: a greeting header, a search bar, a row of
// category filters, and a "Featured Opportunities" list.
//
// The opportunity list is now real, live data from Firestore (see
// OpportunityService.streamActiveOpportunities()) instead of mock data.
// Any startup posting/editing/closing an opportunity anywhere shows up here
// automatically, without the student needing to refresh anything.
class StudentDashboardTab extends StatefulWidget {
  // Called when the user taps "See all" next to Featured Opportunities.
  // student_home_screen.dart passes in a function that switches the
  // bottom nav over to the Search tab, so tapping it feels like a normal
  // in-app link rather than a dead button.
  final VoidCallback? onSeeAllOpportunities;

  const StudentDashboardTab({super.key, this.onSeeAllOpportunities});

  @override
  State<StudentDashboardTab> createState() => _StudentDashboardTabState();
}

class _StudentDashboardTabState extends State<StudentDashboardTab> {
  final FirestoreService _firestoreService = FirestoreService();
  final OpportunityService _opportunityService = OpportunityService();

  // Controls the search bar's text field. The Home tab doesn't filter
  // anything itself when you type here - tapping it just jumps straight to
  // the Search tab, where the same query can actually filter opportunities.
  final TextEditingController _searchController = TextEditingController();

  StudentModel? _studentProfile;
  int _selectedCategoryIndex = 0;

  // Created ONCE (not inside build()) so we subscribe to Firestore a single
  // time. Re-creating the stream on every build would resubscribe on every
  // rebuild (e.g. every time the category filter changes), which is wasteful
  // and can cause the list to briefly flicker back to a loading state.
  late final Stream<List<Opportunity>> _opportunitiesStream =
      _opportunityService.streamActiveOpportunities();

  // The categories row shown under "Categories". "All" plus every category
  // from the shared opportunityCategories list (utils/categories.dart), so
  // this row always matches whatever categories the post form offers.
  late final List<_CategoryData> _categories = [
    const _CategoryData(Icons.apps, 'All'),
    ...opportunityCategories.map((c) => _CategoryData(c.icon, c.label)),
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  // Fetches the logged-in student's profile so we can greet them by name
  // (e.g. "Ralph") instead of showing their raw email address.
  Future<void> _loadStudentProfile() async {
    final uid = context.read<AuthProvider>().appUser?.uid;
    if (uid == null) return;

    final profile = await _firestoreService.getStudentProfile(uid);
    if (!mounted) return;
    setState(() => _studentProfile = profile);
  }

  // Every TextEditingController must be disposed when its widget is
  // removed, otherwise it leaks memory.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    // The colored top bar is now a fixed element outside the scroll view
    // (instead of scrolling away with the rest of the content), so it
    // reads as a proper "app bar" - same brand color as every real AppBar
    // in the app (see main.dart's appBarTheme).
    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Categories'),
                  const SizedBox(height: 12),
                  _buildCategoriesRow(),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Featured Opportunities',
                    onSeeAll: widget.onSeeAllOpportunities,
                  ),
                  const SizedBox(height: 12),
                  _buildOpportunitiesList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Listens to the live opportunities stream and shows the right thing for
  // each of the three states a Firestore stream can be in: still loading,
  // errored, or has data (which may be an empty list).
  Widget _buildOpportunitiesList() {
    final selectedCategory = _categories[_selectedCategoryIndex].label;

    return StreamBuilder<List<Opportunity>>(
      stream: _opportunitiesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Could not load opportunities. Please try again.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final allOpportunities = snapshot.data ?? [];

        // "All" shows everything; any other category filters the list
        // down to opportunities that match it.
        final visibleOpportunities = selectedCategory == 'All'
            ? allOpportunities
            : allOpportunities
                .where((opportunity) => opportunity.category == selectedCategory)
                .toList();

        if (visibleOpportunities.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No opportunities in this category yet.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: visibleOpportunities
              .map(
                (opportunity) => OpportunityCard(
                  opportunity: opportunity,
                  onTap: () => _openDetail(opportunity),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final firstName = _studentProfile?.fullName.split(' ').first ?? '';

    return AppTopBar(
      title: firstName,
      // Wrapped in a Builder so this IconButton's context is below the
      // Scaffold that owns the drawer (see student_home_screen.dart).
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchBarField(controller: _searchController);
  }

  Widget _buildCategoriesRow() {
    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return CategoryChip(
            icon: category.icon,
            label: category.label,
            isSelected: index == _selectedCategoryIndex,
            onTap: () => setState(() => _selectedCategoryIndex = index),
          );
        },
      ),
    );
  }
}

// Small private helper class pairing an icon with a category label, used
// only to build the _categories list above.
class _CategoryData {
  final IconData icon;
  final String label;
  const _CategoryData(this.icon, this.label);
}
