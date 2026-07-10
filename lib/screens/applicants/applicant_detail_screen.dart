import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/application.dart';
import '../../models/student_model.dart';
import '../../services/application_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/avatar_style.dart';
import '../../widgets/decision_button.dart';
import '../../widgets/status_badge.dart';

// Full-screen view of one applicant, opened by tapping their row on the
// startup's "View Applicants" tab. Shows the student's full profile (bio,
// skills, contact info, specialization) plus the Accept/Reject actions -
// this is now the ONLY place those actions live; the list row itself is
// just for scanning.
//
// Both the student's profile AND the application's status are watched
// LIVE (StreamBuilder), not fetched once - so if the student updates their
// bio/skills, or the status changes from another device, this screen
// reflects it immediately.
class ApplicantDetailScreen extends StatefulWidget {
  final Application application;

  const ApplicantDetailScreen({super.key, required this.application});

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ApplicationService _applicationService = ApplicationService();

  late final Stream<StudentModel?> _studentStream;
  late final Stream<Application?> _applicationStream;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _studentStream =
        _firestoreService.streamStudentProfile(widget.application.studentId);
    _applicationStream = _applicationService.streamApplication(
      widget.application.opportunityId,
      widget.application.studentId,
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await _applicationService.updateStatus(widget.application, newStatus);
    } catch (e) {
      // Same debugging pattern used everywhere else in the app.
      debugPrint('Failed to update application status: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No colors set here - the AppBar automatically picks up the brand
      // color + centered title from main.dart's global appBarTheme.
      appBar: AppBar(title: const Text('Applicant Details')),
      body: SafeArea(
        child: StreamBuilder<StudentModel?>(
          stream: _studentStream,
          builder: (context, studentSnapshot) {
            if (studentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final student = studentSnapshot.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(student),
                  const SizedBox(height: 24),
                  _buildInfoTile(
                    Icons.email_outlined,
                    'Email',
                    // Falls back to the denormalized email stored on the
                    // application itself if the student profile can't be
                    // loaded for some reason - so this screen still shows
                    // something useful instead of going blank.
                    student?.email ?? widget.application.studentEmail,
                  ),
                  _buildInfoTile(
                    Icons.phone_outlined,
                    'Phone',
                    student?.phone ?? '',
                  ),
                  _buildInfoTile(
                    Icons.location_on_outlined,
                    'Location',
                    student?.address ?? '',
                  ),
                  _buildInfoTile(
                    Icons.school_outlined,
                    'Specialization',
                    student?.program ?? '',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bio',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (student == null || student.bio.isEmpty)
                        ? 'No bio added yet.'
                        : student.bio,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: (student == null || student.bio.isEmpty)
                          ? Colors.grey.shade500
                          : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Skills',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  (student == null || student.skills.isEmpty)
                      ? Text(
                          'No skills added yet.',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: student.skills
                              .map((skill) => Chip(
                                    label: Text(
                                      skill,
                                      style: const TextStyle(fontSize: 12.5),
                                    ),
                                    backgroundColor: AppColors.lightGrey,
                                    side: BorderSide.none,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 20),
                  _buildDecisionSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(StudentModel? student) {
    final name = student?.fullName ?? widget.application.studentName;
    final initials = initialsFromName(name);
    final avatarColor = colorFromName(name);

    return Row(
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
                name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                'Applied for ${widget.application.opportunityTitle}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not set' : value,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty ? Colors.grey.shade400 : Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Watches the application's status live and shows a badge + the
  // Accept/Reject actions. Both buttons always stay tappable (reversible
  // decision) - whichever matches the CURRENT status renders solid/filled.
  Widget _buildDecisionSection() {
    return StreamBuilder<Application?>(
      stream: _applicationStream,
      builder: (context, snapshot) {
        final application = snapshot.data ?? widget.application;
        final isAccepted = application.status == ApplicationStatus.accepted;
        final isRejected = application.status == ApplicationStatus.rejected;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Application status',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                StatusBadge(status: application.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DecisionButton(
                    label: 'Accept',
                    color: Colors.green,
                    isActive: isAccepted,
                    onPressed: _isUpdating
                        ? null
                        : () => _updateStatus(ApplicationStatus.accepted),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DecisionButton(
                    label: 'Reject',
                    color: Colors.red,
                    isActive: isRejected,
                    onPressed: _isUpdating
                        ? null
                        : () => _updateStatus(ApplicationStatus.rejected),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
