import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/student_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/avatar_style.dart';
import '../../../widgets/app_top_bar.dart';
import '../../../widgets/primary_button.dart';
import '../../profile/student_profile_edit_screen.dart';

// The "Profile" tab a Student sees in the bottom nav: their own info, with
// an Edit button that opens StudentProfileEditScreen.
//
// This uses a live Firestore STREAM (not a one-time fetch) for the
// profile, same pattern as every other data-backed tab in the app. The
// nice side effect: after saving an edit and popping back here, there's no
// manual "refresh" step needed - the moment Firestore confirms the write,
// this screen already shows the new info.
class StudentProfileTab extends StatefulWidget {
  const StudentProfileTab({super.key});

  @override
  State<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends State<StudentProfileTab> {
  final FirestoreService _firestoreService = FirestoreService();

  late final Stream<StudentModel?> _profileStream;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().appUser?.uid ?? '';
    _profileStream = _firestoreService.streamStudentProfile(uid);
  }

  void _openEdit(StudentModel student) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentProfileEditScreen(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppTopBar(title: 'Profile'),
        Expanded(
          child: SafeArea(
            top: false,
            child: _buildBody(),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return StreamBuilder<StudentModel?>(
      stream: _profileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final student = snapshot.data;
        if (student == null) {
          return const Center(
            child: Text(
              'Could not load your profile.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(student),
              const SizedBox(height: 24),
              _buildInfoTile(Icons.email_outlined, 'Email', student.email),
              _buildInfoTile(Icons.phone_outlined, 'Phone', student.phone),
              _buildInfoTile(Icons.home_outlined, 'Address', student.address),
              const SizedBox(height: 12),
              _buildSectionTitle('Bio'),
              const SizedBox(height: 6),
              Text(
                student.bio.isEmpty ? 'No bio added yet.' : student.bio,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: student.bio.isEmpty
                      ? Colors.grey.shade500
                      : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Skills'),
              const SizedBox(height: 8),
              student.skills.isEmpty
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
              PrimaryButton(
                label: 'Edit Profile',
                onPressed: () => _openEdit(student),
              ),
              const SizedBox(height: 12),
              _buildLogoutButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(StudentModel student) {
    final initials = initialsFromName(student.fullName);
    final avatarColor = colorFromName(student.fullName);

    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: avatarColor,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.fullName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                student.program.isEmpty ? 'No program set' : student.program,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  // No Builder wrapper needed here (unlike the drawer's menu icon) - we're
  // not calling Scaffold.of(context), just reading the AuthProvider, which
  // works fine with this State's own `context`.
  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: () => context.read<AuthProvider>().logout(),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        minimumSize: const Size(double.infinity, 46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.logout, size: 18),
      label: const Text('Log out'),
    );
  }
}
