import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import 'tabs/startup_applicants_tab.dart';
import 'tabs/startup_dashboard_tab.dart';
import 'tabs/startup_opportunities_tab.dart';
import 'tabs/startup_profile_tab.dart';

// The Startup's main screen after logging in: a bottom-navigation shell
// with 4 tabs (Home, Opportunities, Applicants, Profile), matching the
// sample UI design we were given.
//
// All four tabs are now fully built out, backed by real Firestore data.
class StartupHomeScreen extends StatefulWidget {
  const StartupHomeScreen({super.key});

  @override
  State<StartupHomeScreen> createState() => _StartupHomeScreenState();
}

class _StartupHomeScreenState extends State<StartupHomeScreen> {
  // Index into the bottom nav / _tabs list. 0 = Home, 1 = Opportunities,
  // 2 = Applicants, 3 = Profile.
  int _currentIndex = 0;

  // Named so `_goToOpportunitiesTab` below stays readable instead of a
  // bare `1`.
  static const int _opportunitiesTabIndex = 1;

  void _goToOpportunitiesTab() =>
      setState(() => _currentIndex = _opportunitiesTabIndex);

  // Built as a getter (instead of a `const` field) because the Home tab
  // needs a callback - `_goToOpportunitiesTab` - wired into it, and
  // callbacks can't be part of a const widget.
  List<Widget> get _tabs => [
        StartupDashboardTab(onSeeAllOpportunities: _goToOpportunitiesTab),
        const StartupOpportunitiesTab(),
        const StartupApplicantsTab(),
        const StartupProfileTab(),
      ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      drawer: _buildDrawer(authProvider),
      // IndexedStack keeps every tab's state alive in the background
      // instead of rebuilding it each time you switch tabs.
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Opportunities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Applicants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // A simple side drawer (opened via the menu icon on the Home tab) that
  // shows the logged-in account's email and lets them log out - mirrors
  // the Student drawer exactly, just labelled as a Startup account.
  Widget _buildDrawer(AuthProvider authProvider) {
    final email = authProvider.appUser?.email ?? '';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.storefront, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Text(
                    'Startup account',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => authProvider.logout(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
