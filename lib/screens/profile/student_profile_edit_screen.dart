import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/student_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

// Lets a Student edit the profile info they can change themselves. Email
// is deliberately NOT editable here - it's tied to their Firebase Auth
// account, and changing it safely would require a re-authentication flow.
// That's more complexity than this project needs, so email stays
// read-only (shown, but not editable) both here and on the view screen.
class StudentProfileEditScreen extends StatefulWidget {
  final StudentModel student;

  const StudentProfileEditScreen({super.key, required this.student});

  @override
  State<StudentProfileEditScreen> createState() =>
      _StudentProfileEditScreenState();
}

class _StudentProfileEditScreenState extends State<StudentProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _programController = TextEditingController();
  final _bioController = TextEditingController();
  // Same comma-separated approach used for an opportunity's required
  // skills (see opportunity_form_screen.dart) - simple to type, simple to
  // parse, no extra chip-input UI needed.
  final _skillsController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _fullNameController.text = student.fullName;
    _phoneController.text = student.phone;
    _addressController.text = student.address;
    _programController.text = student.program;
    _bioController.text = student.bio;
    _skillsController.text = student.skills.join(', ');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _programController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  List<String> _parseSkills() {
    return _skillsController.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      // We rebuild the FULL model (not a partial map) because
      // FirestoreService.saveStudentProfile uses `.set()`, which replaces
      // the whole document - so uid/email/createdAt must be carried over
      // unchanged from the original profile, not left out.
      final updated = StudentModel(
        uid: widget.student.uid,
        fullName: _fullNameController.text.trim(),
        email: widget.student.email,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        program: _programController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _parseSkills(),
        createdAt: widget.student.createdAt,
      );

      await _firestoreService.saveStudentProfile(updated);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    } catch (e) {
      // Same debugging pattern used everywhere else in the app - the real
      // Firestore error prints to the terminal instead of being swallowed.
      debugPrint('Failed to update student profile: $e');
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
      // No colors set here - the AppBar automatically picks up the brand
      // color from main.dart's global appBarTheme.
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
                  controller: _fullNameController,
                  label: 'Full name',
                  icon: Icons.person_outline,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Full name'),
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
                  controller: _programController,
                  label: 'Program',
                  icon: Icons.menu_book_outlined,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Program'),
                ),
                CustomTextField(
                  controller: _bioController,
                  label: 'Bio (optional)',
                  icon: Icons.info_outline,
                  maxLines: 4,
                ),
                CustomTextField(
                  controller: _skillsController,
                  label: 'Skills (comma separated, optional)',
                  icon: Icons.checklist_outlined,
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
