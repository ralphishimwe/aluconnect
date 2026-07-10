import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// A full-width colored bar used at the top of every main tab screen (Home,
// Search, Opportunities, ...).
//
// Why not just use Scaffold's real `appBar:` property here? Because every
// tab lives inside ONE shared Scaffold via IndexedStack (see
// student_home_screen.dart / startup_home_screen.dart), and each tab needs
// slightly different content up top - a name, a verification badge, a "+"
// button, and so on. A real AppBar can't easily change per-tab like that
// while still living inside a single Scaffold, so instead every tab builds
// its own top bar using this shared widget, which guarantees they all look
// consistent and use the same brand color as every real AppBar in the app
// (see main.dart's `appBarTheme`).
//
// The hamburger/menu icon is now ALWAYS shown (baked in here, not passed in
// by each tab) so the drawer is reachable from every tab, not just Home -
// no need for every tab to redeclare its own Builder/IconButton for this.
class AppTopBar extends StatelessWidget {
  final String title;

  // A small action on the far right, e.g. the "+" post button.
  final Widget? trailing;

  // Optional extra line under the title, e.g. the startup's verification
  // badge.
  final Widget? subtitle;

  const AppTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      // SafeArea keeps the bar's content clear of the phone's status bar/
      // notch, without adding bottom padding (the scrollable content below
      // handles that itself).
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Row(
            children: [
              // Wrapped in its own Builder so `Scaffold.of(context)` looks
              // upward from HERE (finding the Scaffold that owns the
              // drawer, defined in student_home_screen.dart /
              // startup_home_screen.dart) rather than from this widget's
              // own position in the tree.
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              // Expanded + CrossAxisAlignment.end floats the title (and
              // subtitle, if any) over to the right side of the bar,
              // instead of sitting immediately next to the menu icon.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      subtitle!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
