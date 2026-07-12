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
// The hamburger/menu icon is ALWAYS shown (baked in here, not passed in by
// each tab) so the drawer is reachable from every tab, not just Home - no
// need for every tab to redeclare its own Builder/IconButton for this.
class AppTopBar extends StatelessWidget {
  final String title;

  // Optional: shows this icon in the centered title spot INSTEAD OF the
  // `title` text (e.g. the Student Home tab uses the app's hub icon instead
  // of the student's name). When this is null (the default), every other
  // tab keeps showing plain text exactly as before.
  final IconData? titleIcon;

  // A small action on the far right, e.g. the "+" post button.
  final Widget? trailing;

  // An extra bit of info shown directly BELOW the title/icon, centered
  // together with it (e.g. the startup's verification badge under its
  // name). `trailing` (the "+" button) stays pinned to the right on its
  // own, completely separate from this.
  final Widget? subtitle;

  const AppTopBar({
    super.key,
    required this.title,
    this.titleIcon,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    // The bar needs a bit more height when there's a subtitle stacked under
    // the title (e.g. the startup's verification badge) - otherwise the
    // extra line would get clipped by the fixed-height box below.
    final barHeight = subtitle != null ? 64.0 : 48.0;

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: SizedBox(
            height: barHeight,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        titleIcon != null
                            ? Icon(titleIcon, color: Colors.white, size: 28)
                            : Text(
                                title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                ),
                // Menu icon, pinned to the left edge.
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ),
                if (trailing != null)
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(child: trailing!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
