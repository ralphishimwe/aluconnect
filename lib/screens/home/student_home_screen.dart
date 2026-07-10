import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import 'tabs/my_applications_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/student_dashboard_tab.dart';
import 'tabs/student_profile_tab.dart';

// The Student's main screen after logging in: a bottom-navigation shell
// with 4 tabs (Home, Search, Applications, Profile), matching the sample
// UI design we were given.
//
// All four tabs are now fully built out, backed by real Firestore data.
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  // Index into the bottom nav / _tabs list. 0 = Home, 1 = Search,
  // 2 = Applications, 3 = Profile.
  int _currentIndex = 0;

  // Named so `_goToSearchTab` below stays readable instead of a bare `1`.
  static const int _searchTabIndex = 1;

  void _goToSearchTab() => setState(() => _currentIndex = _searchTabIndex);

  // Built as a getter (instead of a `const` field) because the Home tab
  // now needs a callback - `_goToSearchTab` - wired into it, and callbacks
  // can't be part of a const widget.
  List<Widget> get _tabs => [
        StudentDashboardTab(onSeeAllOpportunities: _goToSearchTab),
        const SearchTab(),
        const MyApplicationsTab(),
        const StudentProfileTab(),
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
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // A simple side drawer (opened via the menu icon on the Home tab) that
  // shows the logged-in account's email and lets them log out. This keeps
  // logout easy to test without cluttering the Home screen's header.
  Widget _buildDrawer(AuthProvider authProvider) {
    final email = authProvider.appUser?.email ?? '';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              // No color override here anymore - this blends into the
              // Drawer's own background instead of sitting in its own
              // colored box, with just the icon/text left in brand indigo.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.person, color: AppColors.primary, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Student account',
                    style: TextStyle(
                      color: AppColors.primary.withOpacity(0.7),
                      fontSize: 12,
                    ),
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
