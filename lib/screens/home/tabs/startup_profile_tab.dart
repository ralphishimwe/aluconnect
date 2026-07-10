import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/startup_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../utils/avatar_style.dart';
import '../../../widgets/app_top_bar.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/verification_badge.dart';
import '../../profile/startup_profile_edit_screen.dart';

// The "Profile" tab a Startup sees in the bottom nav: its own info, with an
// Edit button that opens StartupProfileEditScreen.
//
// Same live-stream pattern as StudentProfileTab - see that file's comment
// for why this uses FirestoreService.streamStartupProfile instead of a
// one-time fetch.
class StartupProfileTab extends StatefulWidget {
  const StartupProfileTab({super.key});

  @override
  State<StartupProfileTab> createState() => _StartupProfileTabState();
}

class _StartupProfileTabState extends State<StartupProfileTab> {
  final FirestoreService _firestoreService = FirestoreService();

  late final Stream<StartupModel?> _profileStream;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().appUser?.uid ?? '';
    _profileStream = _firestoreService.streamStartupProfile(uid);
  }

  void _openEdit(StartupModel startup) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StartupProfileEditScreen(startup: startup),
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
    return StreamBuilder<StartupModel?>(
      stream: _profileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final startup = snapshot.data;
        if (startup == null) {
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
              _buildHeader(startup),
              const SizedBox(height: 24),
              _buildInfoTile(Icons.email_outlined, 'Email', startup.email),
              _buildInfoTile(Icons.phone_outlined, 'Phone', startup.phone),
              _buildInfoTile(Icons.home_outlined, 'Address', startup.address),
              _buildInfoTile(
                Icons.verified_outlined,
                'ALU affiliation',
                startup.aluAffiliationProof,
              ),
              const SizedBox(height: 12),
              const Text(
                'Description',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                startup.description.isEmpty
                    ? 'No description added yet.'
                    : startup.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: startup.description.isEmpty
                      ? Colors.grey.shade500
                      : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Edit Profile',
                onPressed: () => _openEdit(startup),
              ),
              const SizedBox(height: 12),
              _buildLogoutButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(StartupModel startup) {
    final initials = initialsFromName(startup.name);
    final avatarColor = colorFromName(startup.name);

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
                startup.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                startup.industry.isEmpty ? 'No industry set' : startup.industry,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              VerificationBadge(isVerified: startup.isVerified),
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

  // No Builder wrapper needed - we're only reading AuthProvider, not
  // calling Scaffold.of(context).
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
