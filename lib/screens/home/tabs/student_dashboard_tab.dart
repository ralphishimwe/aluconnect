import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/mock_opportunities.dart';
import '../../../models/student_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/category_chip.dart';
import '../../../widgets/opportunity_card.dart';
import '../../../widgets/search_bar_field.dart';
import '../../../widgets/section_header.dart';

// The "Home" tab a Student sees after logging in. This matches the sample
// UI design we were given: a greeting header, a search bar, a row of
// category filters, and a "Featured Opportunities" list.
//
// The opportunity data shown here is still mock/placeholder data (see
// lib/data/mock_opportunities.dart) - wiring this up to real opportunities
// from Firestore happens in the "Opportunity CRUD" development step. This
// step is only about getting the layout and navigation right.
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

  // Controls the search bar's text field. The Home tab doesn't filter
  // anything itself when you type here - tapping it just jumps straight to
  // the Search tab, where the same query can actually filter opportunities.
  final TextEditingController _searchController = TextEditingController();

  StudentModel? _studentProfile;
  int _selectedCategoryIndex = 0;

  // The categories row shown under "Categories". Each one pairs an icon
  // with the label used to filter the opportunity list below.
  final List<_CategoryData> _categories = const [
    _CategoryData(Icons.apps, 'All'),
    _CategoryData(Icons.code, 'Development'),
    _CategoryData(Icons.edit_outlined, 'Design'),
    _CategoryData(Icons.trending_up, 'Marketing'),
    _CategoryData(Icons.business_center_outlined, 'Business'),
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  // Fetches the logged-in student's profile so we can greet them by name
  // (e.g. "Hello, Ralph 👋") instead of showing their raw email address.
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

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _categories[_selectedCategoryIndex].label;

    // "All" shows everything; any other category filters the mock list
    // down to opportunities that match it.
    final visibleOpportunities = selectedCategory == 'All'
        ? mockOpportunities
        : mockOpportunities
            .where((opportunity) => opportunity.category == selectedCategory)
            .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
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
            // Small note reminding us (and anyone reviewing the code) that
            // this list is still backed by placeholder data.
            if (visibleOpportunities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No opportunities in this category yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...visibleOpportunities.map(
                (opportunity) => OpportunityCard(opportunity: opportunity),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final firstName = _studentProfile?.fullName.split(' ').first ?? '';

    return Row(
      children: [
        // Wrapped in a Builder so this IconButton's context is below the
        // Scaffold that owns the drawer (see student_home_screen.dart).
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        Expanded(
          child: Text(
            firstName.isEmpty ? 'Hello 👋' : 'Hello, $firstName 👋',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
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
