import 'package:flutter/material.dart';

// A small Accept/Reject-style button that switches between a solid, filled
// look (when it's the currently active decision) and an outlined look
// (otherwise) - both states remain tappable either way, which is what
// makes a decision reversible: a startup can flip it again later just by
// tapping the other option.
//
// Shared by anywhere an application's status can be changed (currently
// just the Applicant Detail screen).
class DecisionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;

  // Nullable on purpose - passing `null` (e.g. while a save is in
  // progress) lets ElevatedButton/OutlinedButton show their own built-in
  // disabled/greyed-out look, instead of us having to fake that state.
  final VoidCallback? onPressed;

  const DecisionButton({
    super.key,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}
