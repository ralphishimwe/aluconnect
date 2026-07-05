import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// A reusable search bar (grey rounded box + search icon + text field),
// used on both the Home tab and the Search tab so they look identical.
//
// This widget itself doesn't know what to do with what's typed - it just
// reports every change via [onChanged]. The screen that uses it decides
// how to react (e.g. filter a list of opportunities).
class SearchBarField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const SearchBarField({
    super.key,
    required this.controller,
    this.hintText = 'Search opportunities...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
