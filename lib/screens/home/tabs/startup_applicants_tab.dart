import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/application.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/application_service.dart';
import '../../../widgets/app_top_bar.dart';
import '../../../widgets/applicant_row.dart';

// The "Applicants" tab a Startup sees in the bottom nav: every student who
// has applied to any of this startup's postings, grouped by opportunity so
// it's easy to review "who applied to this specific role" one posting at a
// time, instead of one long mixed list.
//
// Accepting/rejecting is reversible - see ApplicationService.updateStatus
// and ApplicantRow for why both buttons always stay tappable.
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

  Future<void> _updateStatus(Application application, String newStatus) async {
    await _applicationService.updateStatus(application, newStatus);
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

        return ListView(
          children: grouped.entries.map((entry) {
            final opportunityApplications = entry.value;
            final opportunityTitle = opportunityApplications.first.opportunityTitle;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          opportunityTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${opportunityApplications.length} applicant${opportunityApplications.length == 1 ? '' : 's'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...opportunityApplications.map(
                    (application) => ApplicantRow(
                      application: application,
                      onAccept: () => _updateStatus(
                        application,
                        ApplicationStatus.accepted,
                      ),
                      onReject: () => _updateStatus(
                        application,
                        ApplicationStatus.rejected,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
