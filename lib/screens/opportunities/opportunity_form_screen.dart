import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/opportunity.dart';
import '../../services/opportunity_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/categories.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

// One screen handles both "post a brand-new opportunity" and "edit an
// existing one", depending on whether [existingOpportunity] is passed in.
// This avoids maintaining two nearly-identical form screens that would
// drift out of sync over time.
class OpportunityFormScreen extends StatefulWidget {
  final String startupId;
  final String startupName;
  final Opportunity? existingOpportunity;

  const OpportunityFormScreen({
    super.key,
    required this.startupId,
    required this.startupName,
    this.existingOpportunity,
  });

  @override
  State<OpportunityFormScreen> createState() => _OpportunityFormScreenState();
}

class _OpportunityFormScreenState extends State<OpportunityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final OpportunityService _opportunityService = OpportunityService();

  // Dropdown choices for location and work type. Category comes from the
  // shared opportunityCategories list (utils/categories.dart) instead.
  static const _locations = ['Remote', 'On-site'];
  static const _workTypes = ['Full-time', 'Part-time'];

  late String _category;
  late String _location;
  late String _workType;
  late bool _isActive;
  bool _isSaving = false;

  // If we were given an existing opportunity, we're editing it. Otherwise
  // we're creating a brand-new one.
  bool get _isEditing => widget.existingOpportunity != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingOpportunity;
    _titleController.text = existing?.title ?? '';
    _category = existing?.category ?? opportunityCategories.first.label;
    _location = existing?.location ?? _locations.first;
    _workType = existing?.workType ?? _workTypes.first;
    _isActive = existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        await _opportunityService.updateOpportunity(
          widget.existingOpportunity!.id,
          title: _titleController.text.trim(),
          category: _category,
          location: _location,
          workType: _workType,
          isActive: _isActive,
        );
      } else {
        await _opportunityService.createOpportunity(
          startupId: widget.startupId,
          startupName: widget.startupName,
          title: _titleController.text.trim(),
          category: _category,
          location: _location,
          workType: _workType,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isEditing ? 'Opportunity updated.' : 'Opportunity posted!'),
        ),
      );
    } catch (e) {
      // Firestore write failed - could be no internet connection, or (most
      // commonly while building this feature) a security rules problem,
      // e.g. firestore.rules hasn't been published in the Firebase console
      // yet, or this startup's `isVerified` field isn't actually true.
      //
      // debugPrint shows the REAL error in your terminal/IDE console (it
      // won't show up on the phone screen) - if you hit this, check there
      // first. A permission error will print something like:
      // "[cloud_firestore/permission-denied] Missing or insufficient permissions."
      debugPrint('Failed to save opportunity: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    // Deleting is permanent, so we double-check with the user first.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete opportunity?'),
        content: const Text(
          'This will permanently remove this posting. Students will no '
          'longer be able to see or apply to it. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    await _opportunityService.deleteOpportunity(widget.existingOpportunity!.id);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Opportunity deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Opportunity' : 'Post New Opportunity'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete opportunity',
              icon: const Icon(Icons.delete_outline),
              onPressed: _isSaving ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _titleController,
                  label: 'Opportunity title',
                  icon: Icons.title,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Title'),
                ),
                const SizedBox(height: 8),
                _buildDropdown(
                  label: 'Category',
                  value: _category,
                  items: opportunityCategories.map((c) => c.label).toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Location',
                  value: _location,
                  items: _locations,
                  onChanged: (value) => setState(() => _location = value!),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Work type',
                  value: _workType,
                  items: _workTypes,
                  onChanged: (value) => setState(() => _workType = value!),
                ),
                // Only shown while editing - a brand-new posting is always
                // open, so there's nothing to toggle yet at creation time.
                if (_isEditing) ...[
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Posting is open'),
                    subtitle: const Text(
                      'Turn this off once you stop accepting applicants.',
                    ),
                    value: _isActive,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: _isEditing ? 'Save changes' : 'Post opportunity',
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // A simple labeled dropdown, used for category/location/work type. Kept
  // as one small helper method instead of three near-identical widgets.
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
