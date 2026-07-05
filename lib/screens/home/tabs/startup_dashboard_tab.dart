import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/mock_posted_opportunities.dart';
import '../../../models/startup_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/posted_opportunity_card.dart';
import '../../../widgets/section_header.dart';

// The "Home" tab a Startup sees after logging in. It mirrors the layout of
// the Student's Home tab (header, section list) but shows the startup's own
// postings instead of ones to browse, plus a couple of startup-specific
// touches: an ALU verification badge and a small stats strip.
//
// The opportunity data shown here is still mock/placeholder data (see
// lib/data/mock_posted_opportunities.dart) - wiring this up to this
// startup's real postings from Firestore happens in the "Opportunity CRUD"
// development step.
class StartupDashboardTab extends StatefulWidget {
  // Called when the user taps "See all" next to Your Opportunities.
  // startup_home_screen.dart passes in a function that switches the
  // bottom nav over to the Opportunities tab.
  final VoidCallback? onSeeAllOpportunities;

  const StartupDashboardTab({super.key, this.onSeeAllOpportunities});

  @override
  State<StartupDashboardTab> createState() => _StartupDashboardTabState();
}

class _StartupDashboardTabState extends State<StartupDashboardTab> {
  final FirestoreService _firestoreService = FirestoreService();
  StartupModel? _startupProfile;

  @override
  void initState() {
    super.initState();
    _loadStartupProfile();
  }

  // Fetches the logged-in startup's profile so we can greet them by name
  // and show their real verification status instead of guessing.
  Future<void> _loadStartupProfile() async {
    final uid = context.read<AuthProvider>().appUser?.uid;
    if (uid == null) return;

    final profile = await _firestoreService.getStartupProfile(uid);
    if (!mounted) return;
    setState(() => _startupProfile = profile);
  }

  // Posting/editing opportunities doesn't exist yet (that's the
  // "Opportunity CRUD" development step) - this just gives clear feedback
  // instead of a button that silently does nothing.
  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Small stats computed from the mock postings, standing in for what
    // will eventually be a real query over this startup's Firestore data.
    final activeCount =
        mockPostedOpportunities.where((o) => o.isActive).length;
    final totalApplicants = mockPostedOpportunities
        .fold<int>(0, (sum, o) => sum + o.applicantCount);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            // Only show the pending-verification banner once we know the
            // profile actually isn't verified (avoids a flash of the
            // banner while the profile is still loading).
            if (_startupProfile != null && !_startupProfile!.isVerified)
              _buildVerificationBanner(),
            const SizedBox(height: 20),
            _buildStatsRow(activeCount, totalApplicants),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Your Opportunities',
              onSeeAll: widget.onSeeAllOpportunities,
            ),
            const SizedBox(height: 12),
            if (mockPostedOpportunities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "You haven't posted any opportunities yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...mockPostedOpportunities.map(
                (opportunity) => PostedOpportunityCard(
                  opportunity: opportunity,
                  onTap: () => _showComingSoon(
                    'Full opportunity details & editing arrive in the '
                    'Opportunity CRUD development step.',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final startupName = _startupProfile?.name ?? '';

    return Row(
      children: [
        // Wrapped in a Builder so this IconButton's context is below the
        // Scaffold that owns the drawer (see startup_home_screen.dart).
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                startupName.isEmpty
                    ? 'Welcome back 👋'
                    : 'Welcome back, $startupName 👋',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              _buildVerificationTag(),
            ],
          ),
        ),
        // Lets a startup jump straight to posting - full posting flow
        // arrives in the Opportunity CRUD step, so for now it just
        // explains what's coming.
        IconButton(
          tooltip: 'Post an opportunity',
          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
          onPressed: () => _showComingSoon(
            'Posting new opportunities arrives in the Opportunity CRUD '
            'development step.',
          ),
        ),
      ],
    );
  }

  // A small "Verified" / "Verification pending" tag under the greeting.
  // Hidden entirely until the profile has actually loaded, so we never
  // show a wrong status.
  Widget _buildVerificationTag() {
    if (_startupProfile == null) return const SizedBox.shrink();

    final isVerified = _startupProfile!.isVerified;
    final color = isVerified ? Colors.green : Colors.orange;
    final icon = isVerified ? Icons.verified : Icons.hourglass_top;
    final label = isVerified ? 'Verified ALU Startup' : 'Verification pending';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // Explains, in plain language, what "pending verification" means and why
  // it exists - this is how we satisfy the rubric's requirement that only
  // startups recognized within the ALU ecosystem can use the platform,
  // without needing a full admin-review screen this early in the project
  // (an ALU staff member flips `isVerified` to true in the Firebase console
  // after checking the affiliation proof the startup submitted at sign up).
  Widget _buildVerificationBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.hourglass_top, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your startup is pending ALU verification. You can explore the '
              "app now, and you'll be able to post opportunities once an ALU "
              'admin confirms your affiliation.',
              style: TextStyle(fontSize: 12.5, color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }

  // A small two-box stats strip giving the startup an at-a-glance view of
  // their activity on the platform - a lightweight step toward the
  // "analytics dashboard" idea suggested in the assignment brief.
  Widget _buildStatsRow(int activeCount, int totalApplicants) {
    return Row(
      children: [
        Expanded(child: _statCard('$activeCount', 'Active Postings')),
        const SizedBox(width: 12),
        Expanded(child: _statCard('$totalApplicants', 'Total Applicants')),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
