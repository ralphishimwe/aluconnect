import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/opportunity.dart';
import '../../../models/startup_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../services/opportunity_service.dart';
import '../../../utils/verification_gate.dart';
import '../../../widgets/app_top_bar.dart';
import '../../../widgets/posted_opportunity_card.dart';
import '../../opportunities/opportunity_form_screen.dart';

// The "Opportunities" tab a Startup sees in the bottom nav. This is the
// full management screen for everything this startup has posted - the
// Home tab only shows a short preview of the same list.
//
// Just like the Home tab, posting a brand-new opportunity is gated behind
// ALU verification (see utils/verification_gate.dart), while tapping an
// existing card to edit it is always allowed.
class StartupOpportunitiesTab extends StatefulWidget {
  const StartupOpportunitiesTab({super.key});

  @override
  State<StartupOpportunitiesTab> createState() =>
      _StartupOpportunitiesTabState();
}

class _StartupOpportunitiesTabState extends State<StartupOpportunitiesTab> {
  final FirestoreService _firestoreService = FirestoreService();
  final OpportunityService _opportunityService = OpportunityService();

  StartupModel? _startupProfile;
  Stream<List<Opportunity>>? _opportunitiesStream;

  @override
  void initState() {
    super.initState();
    _loadStartupProfile();
  }

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
    // Same fixed colored top bar pattern used on the Home tabs - see
    // widgets/app_top_bar.dart - so every tab looks consistent.
    return Column(
      children: [
        AppTopBar(
          title: 'Your Opportunities',
          trailing: IconButton(
            tooltip: 'Post an opportunity',
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: _openPostForm,
          ),
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _buildList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    if (_opportunitiesStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<Opportunity>>(
      stream: _opportunitiesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Could not load your opportunities. Please try again.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final opportunities = snapshot.data ?? [];

        if (opportunities.isEmpty) {
          return const Center(
            child: Text(
              "You haven't posted any opportunities yet.\nTap + to post your first one.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: opportunities.length,
          itemBuilder: (context, index) {
            final opportunity = opportunities[index];
            return PostedOpportunityCard(
              opportunity: opportunity,
              onTap: () => _openEditForm(opportunity),
            );
          },
        );
      },
    );
  }
}
