import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/startup_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

// Lets a Startup edit its own profile info. Email and isVerified are
// deliberately NOT editable here:
//   - Email is tied to the Firebase Auth account (same reasoning as the
//     Student edit screen - changing it needs a re-authentication flow
//     we're not building for this project).
//   - isVerified is admin-controlled (see startup_model.dart) - a startup
//     editing its own profile should never be able to flip its own
//     verification status, so we simply never expose it as an editable
//     field and always carry the EXISTING value forward unchanged when
//     saving.
class StartupProfileEditScreen extends StatefulWidget {
  final StartupModel startup;

  const StartupProfileEditScreen({super.key, required this.startup});

  @override
  State<StartupProfileEditScreen> createState() =>
      _StartupProfileEditScreenState();
}

class _StartupProfileEditScreenState extends State<StartupProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _industryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _affiliationController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final startup = widget.startup;
    _nameController.text = startup.name;
    _phoneController.text = startup.phone;
    _addressController.text = startup.address;
    _industryController.text = startup.industry;
    _descriptionController.text = startup.description;
    _affiliationController.text = startup.aluAffiliationProof;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    _affiliationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      // Full model rebuild, same reasoning as StudentProfileEditScreen -
      // saveStartupProfile uses `.set()`, so uid/email/isVerified/createdAt
      // must all be carried over from the original, unchanged.
      final updated = StartupModel(
        uid: widget.startup.uid,
        name: _nameController.text.trim(),
        email: widget.startup.email,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        industry: _industryController.text.trim(),
        description: _descriptionController.text.trim(),
        aluAffiliationProof: _affiliationController.text.trim(),
        isVerified: widget.startup.isVerified,
        createdAt: widget.startup.createdAt,
      );

      await _firestoreService.saveStartupProfile(updated);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    } catch (e) {
      debugPrint('Failed to update startup profile: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Startup / organization name',
                  icon: Icons.rocket_launch_outlined,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Startup name'),
                ),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                CustomTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.home_outlined,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Address'),
                ),
                CustomTextField(
                  controller: _industryController,
                  label: 'Industry',
                  icon: Icons.business_outlined,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Industry'),
                ),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),
                CustomTextField(
                  controller: _affiliationController,
                  label: 'How is this startup recognized at ALU?',
                  icon: Icons.verified_outlined,
                  validator: (value) => Validators.required(
                    value,
                    fieldName: 'ALU affiliation proof',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8, left: 4, right: 4),
                  child: Text(
                    'Editing this does NOT change your verification status - '
                    'an ALU admin will see the updated info the next time '
                    'they review it.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Save changes',
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
}
