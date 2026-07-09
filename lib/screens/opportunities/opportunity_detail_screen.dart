import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../models/opportunity.dart';
import '../../models/student_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/application_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/avatar_style.dart';
import '../../utils/categories.dart';
import '../../utils/time_ago.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';

// Full-screen view of one opportunity, opened by tapping a card on the
// Student Home or Search tab. This is where the actual "Apply" action
// lives - the cards themselves are just a preview.
//
// Whether this student has already applied is watched LIVE via
// ApplicationService.streamApplication, not a one-time check. That means
// if a startup accepts/rejects the application while the student happens
// to have this screen open, the status updates on screen immediately -
// this is our "real-time updates" requirement showing up in a second place
// beyond the opportunity lists themselves.
class OpportunityDetailScreen extends StatefulWidget {
  final Opportunity opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ApplicationService _applicationService = ApplicationService();

  StudentModel? _studentProfile;
  bool _isSubmitting = false;

  // Created once we know who's logged in, so we only subscribe to
  // Firestore a single time for this screen.
  late final Stream<Application?> _applicationStream;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().appUser?.uid ?? '';
    _applicationStream =
        _applicationService.streamApplication(widget.opportunity.id, uid);
    _loadStudentProfile();
  }

  // We need the student's name (not just their uid) to store on the
  // application document - see ApplicationService.apply.
  Future<void> _loadStudentProfile() async {
    final uid = context.read<AuthProvider>().appUser?.uid;
    if (uid == null) return;

    final profile = await _firestoreService.getStudentProfile(uid);
    if (!mounted) return;
    setState(() => _studentProfile = profile);
  }

  Future<void> _apply() async {
    final uid = context.read<AuthProvider>().appUser?.uid;
    final studentName = _studentProfile?.fullName;
    final studentEmail = _studentProfile?.email;
    if (uid == null || studentName == null || studentEmail == null) return;

    setState(() => _isSubmitting = true);
    try {
      await _applicationService.apply(
        opportunity: widget.opportunity,
        studentId: uid,
        studentName: studentName,
        studentEmail: studentEmail,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted!')),
      );
    } catch (e) {
      // Same debugging pattern as opportunity_form_screen.dart - the real
      // Firestore error (e.g. a permission-denied if firestore.rules
      // hasn't been published yet) prints to the terminal instead of being
      // silently swallowed.
      debugPrint('Failed to submit application: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
            child: const Text('Withdraw', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      await _applicationService.withdraw(application);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application withdrawn.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final opportunity = widget.opportunity;
    final initials = initialsFromName(opportunity.startupName);
    final avatarColor = colorFromName(opportunity.startupName);

    return Scaffold(
      // No need to set colors here - the AppBar automatically picks up the
      // brand color from main.dart's global appBarTheme.
      appBar: AppBar(title: const Text('Opportunity Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          opportunity.startupName,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _DetailChip(
                    icon: iconForCategory(opportunity.category),
                    label: opportunity.category,
                  ),
                  _DetailChip(
                    icon: Icons.location_on_outlined,
                    label: opportunity.location,
                  ),
                  _DetailChip(
                    icon: Icons.schedule,
                    label: opportunity.workType,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Posted ${timeAgo(opportunity.createdAt)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              // Both of these are optional fields on the opportunity (a
              // startup might skip them when posting), so we only show
              // each section if there's actually something to show.
              if (opportunity.description.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  opportunity.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
              if (opportunity.requiredSkills.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Required skills',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: opportunity.requiredSkills
                      .map((skill) => Chip(
                            label: Text(
                              skill,
                              style: const TextStyle(fontSize: 12.5),
                            ),
                            backgroundColor: AppColors.lightGrey,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 20),
              _buildApplySection(),
            ],
          ),
        ),
      ),
    );
  }

  // Watches this student's application to this opportunity in real time,
  // and shows the right thing for each state: not applied yet, already
  // applied (with live status), or still loading.
  Widget _buildApplySection() {
    return StreamBuilder<Application?>(
      stream: _applicationStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final application = snapshot.data;

        if (application == null) {
          // The student's profile is still loading in the background (see
          // _loadStudentProfile) - we need their name before we can submit
          // an application, so keep the button in its loading/disabled
          // state instead of letting a tap silently do nothing.
          final profileReady = _studentProfile != null;

          return PrimaryButton(
            label: 'Apply now',
            isLoading: _isSubmitting || !profileReady,
            onPressed: profileReady ? _apply : null,
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'You applied',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  StatusBadge(status: application.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Applied ${timeAgo(application.appliedAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              // Withdrawing only makes sense while the startup hasn't
              // decided yet - once accepted/rejected, the decision is
              // final, so we hide this option.
              if (application.status == ApplicationStatus.underReview) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isSubmitting ? null : () => _withdraw(application),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Withdraw application'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// A small pill showing one piece of opportunity metadata (category,
// location, or work type) with an icon - bigger and more spaced out than
// the tiny _MetaTag rows used inside the list cards, since this screen has
// more room to work with.
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
