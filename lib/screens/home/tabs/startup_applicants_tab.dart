import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/application.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/application_service.dart';
import '../../../widgets/app_top_bar.dart';
import '../../../widgets/applicant_row.dart';
import '../../applicants/applicant_detail_screen.dart';

// The "Applicants" tab a Startup sees in the bottom nav: every student who
// has applied to any of this startup's postings, grouped by opportunity so
// it's easy to review "who applied to this specific role" one posting at a
// time, instead of one long mixed list.
//
// Each opportunity is its own Card containing a compact list of applicant
// rows (see widgets/applicant_row.dart) - tapping a row opens the full
// Applicant Detail screen, which is where Accept/Reject actually live now
// (see screens/applicants/applicant_detail_screen.dart). This tab itself is
// just for browsing/scanning, not for taking action.
class StartupApplicantsTab extends StatefulWidget {
  const StartupApplicantsTab({super.key});

  @override
  State<StartupApplicantsTab> createState() => _StartupApplicantsTabState();
}

class _StartupApplicantsTabState extends State<StartupApplicantsTab> {
  final ApplicationService _applicationService = ApplicationService();

  // Created once in initState, same pattern used by every other tab.
  late final Stream<List<Application>> _applicationsStream;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().appUser?.uid ?? '';
    _applicationsStream = _applicationService.streamByStartup(uid);
  }

  void _openApplicantDetail(Application application) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ApplicantDetailScreen(application: application),
      ),
    );
  }

  // Groups a flat list of applications into sections keyed by
  // opportunityId, preserving the order they first appear in (the list
  // itself is already sorted most-recent-first, so this naturally puts
  // whichever posting got applied to most recently near the top).
  Map<String, List<Application>> _groupByOpportunity(
    List<Application> applications,
  ) {
    final grouped = <String, List<Application>>{};
    for (final application in applications) {
      grouped.putIfAbsent(application.opportunityId, () => []).add(application);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppTopBar(title: 'Applicants'),
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
    return StreamBuilder<List<Application>>(
      stream: _applicationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Could not load applicants. Please try again.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final applications = snapshot.data ?? [];

        if (applications.isEmpty) {
          return const Center(
            child: Text(
              "No one has applied to your opportunities yet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final grouped = _groupByOpportunity(applications);
        final groups = grouped.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            return _buildOpportunityCard(groups[index].value);
          },
        );
      },
    );
  }

  // One Card per opportunity: a header (title + applicant count) followed
  // by a compact list of applicant rows, separated by thin dividers -
  // scans much better than a full elevated card per applicant.
  Widget _buildOpportunityCard(List<Application> applicants) {
    final opportunityTitle = applicants.first.opportunityTitle;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    opportunityTitle,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${applicants.length} applicant${applicants.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            for (final application in applicants) ...[
              const Divider(height: 20),
              ApplicantRow(
                application: application,
                onTap: () => _openApplicantDetail(application),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
