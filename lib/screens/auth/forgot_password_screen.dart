import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

/// Forgot password screen. It calls AuthProvider.sendPasswordReset().
/// In Phase 5 the provider will send a real Firebase reset email,
/// and this screen will not need to change.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // True after the reset link has been sent.
  bool _linkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Checks the email format.
  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  // Runs when the Send Reset Link button is pressed.
  Future<void> _handleSendLink() async {
    // Stop here if the email has an error.
    if (!_formKey.currentState!.validate()) return;

    // Hide the keyboard.
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final bool success = await auth.sendPasswordReset(_emailController.text);

    if (!mounted) return;

    if (success) {
      setState(() => _linkSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Could not send the link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch: the button shows a spinner while the provider is working.
    final bool isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          // Smoothly switches between the form and the confirmation.
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _linkSent
                ? _buildSuccessView()
                : _buildFormView(isLoading),
          ),
        ),
      ),
    );
  }

  // The form where the user types their email.
  Widget _buildFormView(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in a soft circle
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.lightApricot,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 38,
              color: AppColors.terracotta,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Forgot password?',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Enter your email and we'll send you a link to reset your password.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          CustomTextField(
            label: 'Email',
            hint: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: _validateEmail,
          ),
          const SizedBox(height: 32),

          CustomButton(
            label: 'Send Reset Link',
            isLoading: isLoading,
            onPressed: _handleSendLink,
          ),
        ],
      ),
    );
  }

  // The confirmation shown after the link is sent.
  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey('success'),
      children: [
        const SizedBox(height: 40),
        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            color: AppColors.lightApricot,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 54,
            color: AppColors.terracotta,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We sent a password reset link to\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 36),
        CustomButton(
          label: 'Back to Login',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}