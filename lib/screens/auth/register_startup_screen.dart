import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

// Registration form for Startups / student-led ventures.
// Collects: name, email, phone, address, industry, an "ALU affiliation
// proof" field, and password.
//
// The "ALU affiliation proof" field is what lets us satisfy the rubric's
// requirement that only startups genuinely recognized at ALU can use the
// platform: every startup starts unverified (see startup_model.dart) and
// this text is what an admin checks before flipping isVerified to true.
class RegisterStartupScreen extends StatefulWidget {
  const RegisterStartupScreen({super.key});

  @override
  State<RegisterStartupScreen> createState() => _RegisterStartupScreenState();
}

class _RegisterStartupScreenState extends State<RegisterStartupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _industryController = TextEditingController();
  final _affiliationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _industryController.dispose();
    _affiliationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.registerStartup(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      industry: _industryController.text,
      aluAffiliationProof: _affiliationController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(authProvider.errorMessage ?? 'Registration failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Startup Registration')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Startup / organization name',
                  icon: Icons.rocket_launch_outlined,
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Startup name'),
                ),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
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
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Address'),
                ),
                CustomTextField(
                  controller: _industryController,
                  label: 'Industry (e.g. EdTech, Fintech)',
                  icon: Icons.business_outlined,
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Industry'),
                ),
                CustomTextField(
                  controller: _affiliationController,
                  label: 'How is this startup recognized at ALU?',
                  icon: Icons.verified_outlined,
                  validator: (v) => Validators.required(v,
                      fieldName: 'ALU affiliation proof'),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8, left: 4, right: 4),
                  child: Text(
                    'e.g. "ALU Innovation Hub member", incubation program '
                    'name, or a staff sponsor. This is reviewed before your '
                    'startup is marked as verified and allowed to post.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: Validators.password,
                ),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Create account',
                  isLoading: authProvider.isLoading,
                  onPressed: _handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
