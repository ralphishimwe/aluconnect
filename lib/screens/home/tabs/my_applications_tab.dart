import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/application.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/application_service.dart';
import '../../../widgets/app_top_bar.dart';
import '../../../widgets/application_card.dart';

// The "Applications" tab a Student sees in the bottom nav: a live list of
// every opportunity they've applied to, each with its current status
// (Under review / Accepted / Rejected).
//
// The status field itself is only ever changed by a startup, from the
// upcoming "View Applicants" step - this tab doesn't do that update, it
// just reflects whatever the current status is, live, via StreamBuilder.
class MyApplicationsTab extends StatefulWidget {
  const MyApplicationsTab({super.key});

  @override
  State<MyApplicationsTab> createState() => _MyApplicationsTabState();
}

class _MyApplicationsTabState extends State<MyApplicationsTab> {
  final ApplicationService _applicationService = ApplicationService();

  // Created once in initState (not inside build()) so we only subscribe to
  // Firestore a single time - same pattern used by the other tabs.
  late final Stream<List<Application>> _applicationsStream;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().appUser?.uid ?? '';
    _applicationsStream = _applicationService.streamByStudent(uid);
  }

  Future<void> _withdraw(Application application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: const Text(
          "You can apply again later if you change your mind, but the "
          "startup won't see this application anymore.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Withdraw',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _applicationService.withdraw(application);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application withdrawn.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Same fixed colored top bar pattern used on every other tab - see
    // widgets/app_top_bar.dart.
    return Column(
      children: [
        const AppTopBar(title: 'My Applications'),
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
              'Could not load your applications. Please try again.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final applications = snapshot.data ?? [];

        if (applications.isEmpty) {
          return const Center(
            child: Text(
              "You haven't applied to any opportunities yet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final application = applications[index];
            return ApplicationCard(
              application: application,
              onWithdraw: () => _withdraw(application),
            );
          },
        );
      },
    );
  }
}
