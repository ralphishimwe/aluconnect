import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/opportunity.dart';
import '../../../models/startup_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../services/opportunity_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/verification_gate.dart';
import '../../../widgets/app_top_bar.dart';
import '../../../widgets/posted_opportunity_card.dart';
import '../../../widgets/section_header.dart';
import '../../opportunities/opportunity_form_screen.dart';

// The "Home" tab a Startup sees after logging in. It mirrors the layout of
// the Student's Home tab (header, section list) but shows the startup's own
// postings instead of ones to browse, plus a couple of startup-specific
// touches: an ALU verification badge and a small stats strip.
//
// The opportunity list is now this startup's real postings from Firestore
// (see OpportunityService.streamByStartup) instead of mock data. Only a
// verified startup can actually reach the post form - see
// utils/verification_gate.dart for the shared check used by both the "+"
// button here and the one on the Opportunities tab.
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
  final OpportunityService _opportunityService = OpportunityService();
  StartupModel? _startupProfile;

  // Only created once we know the startup's uid (see _loadStartupProfile),
  // so we can't make this `late final` at declaration time like the
  // student-side tabs do. It's still only created once per uid though.
  Stream<List<Opportunity>>? _opportunitiesStream;

  @override
  void initState() {
    super.initState();
    _loadStartupProfile();
  }

  // Fetches the logged-in startup's profile so we can greet them by name
  // and show their real verification status instead of guessing. Also
  // starts the live stream of this startup's own postings, now that we
  // know their uid.
  Future<void> _loadStartupProfile() async {
    final uid = context.read<AuthProvider>().appUser?.uid;
    if (uid == null) return;

    final profile = await _firestoreService.getStartupProfile(uid);
    if (!mounted) return;
    setState(() {
      _startupProfile = profile;
      _opportunitiesStream = _opportunityService.streamByStartup(uid);
    });
  }

  // Opens the post form, but only if this startup is verified - see
  // utils/verification_gate.dart.
  void _openPostForm() {
    final profile = _startupProfile;
    final uid = context.read<AuthProvider>().appUser?.uid;
    if (profile == null || uid == null) return;

    requireVerifiedStartup(context, profile, () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OpportunityFormScreen(
            startupId: uid,
            startupName: profile.name,
          ),
        ),
      );
    });
  }

  // Opens the edit/delete form for an existing posting. Editing an existing
  // posting is always allowed (no verification check needed) since it was
  // only ever created by a verified startup in the first place.
  void _openEditForm(Opportunity opportunity) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OpportunityFormScreen(
          startupId: opportunity.startupId,
          startupName: opportunity.startupName,
          existingOpportunity: opportunity,
        ),
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
                  // Only show the pending-verification banner once we know
                  // the profile actually isn't verified (avoids a flash of
                  // the banner while the profile is still loading).
                  if (_startupProfile != null && !_startupProfile!.isVerified)
                    _buildVerificationBanner(),
                  const SizedBox(height: 20),
                  _buildOpportunitiesSection(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Listens to this startup's live opportunities stream, and builds the
  // stats row + "Your Opportunities" list from whatever it currently holds.
  Widget _buildOpportunitiesSection() {
    if (_opportunitiesStream == null) {
      // Profile (and therefore the stream) hasn't loaded yet.
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

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
              'Could not load your opportunities. Please try again.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final opportunities = snapshot.data ?? [];
        final activeCount = opportunities.where((o) => o.isActive).length;
        final totalApplicants = opportunities.fold<int>(
          0,
          (sum, o) => sum + o.applicantCount,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(activeCount, totalApplicants),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Your Opportunities',
              onSeeAll: widget.onSeeAllOpportunities,
            ),
            const SizedBox(height: 12),
            if (opportunities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "You haven't posted any opportunities yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...opportunities.map(
                (opportunity) => PostedOpportunityCard(
                  opportunity: opportunity,
                  onTap: () => _openEditForm(opportunity),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final startupName = _startupProfile?.name ?? '';

    return AppTopBar(
      title: startupName,
      // Wrapped in a Builder so this IconButton's context is below the
      // Scaffold that owns the drawer (see startup_home_screen.dart).
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      subtitle: _buildVerificationTag(),
      // Lets a verified startup jump straight to posting a new
      // opportunity. Unverified startups tapping this see an explanation
      // dialog instead - see _openPostForm / requireVerifiedStartup.
      trailing: IconButton(
        tooltip: 'Post an opportunity',
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        onPressed: _openPostForm,
      ),
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
