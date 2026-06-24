import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unihub/core/routing/app_router.dart';
import 'package:unihub/features/auth/services/auth_service.dart';
import 'package:unihub/features/auth/widgets/auth_text_field.dart';
import 'package:unihub/features/auth/widgets/social_login_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _collegeController = TextEditingController();
  final _courseController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _selectedYear;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _collegeController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await _authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          college: _collegeController.text.trim().isEmpty
              ? null
              : _collegeController.text.trim(),
          year: _selectedYear,
          course: _courseController.text.trim().isEmpty
              ? null
              : _courseController.text.trim(),
        );
      } else {
        await _authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && mounted) {
        context.go(AppRoutes.home);
      } else if (mounted && result == null) {
        // User cancelled - don't show error
        setState(() => _errorMessage = null);
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('oauth_client') ||
          errorMsg.contains('ID token is null') ||
          errorMsg.contains('10:')) {
        errorMsg =
            'Google Sign-In not configured. Please add your debug SHA-1 fingerprint to the Firebase Console under Project Settings → Your App → SHA certificate fingerprints.';
      }
      if (mounted) {
        setState(() => _errorMessage = errorMsg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email first');
      return;
    }

    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent!',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Icon(
                      Icons.school_rounded,
                      size: 80,
                      color: colorScheme.primary,
                    ).animate().scale(
                        delay: 100.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutBack),
                    const SizedBox(height: 24),
                    Text(
                      _isSignUp ? 'Create an Account' : 'Welcome Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp ? 'Join UniHub today' : 'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 32),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: colorScheme.error.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: -0.1, end: 0),

                    // Input Fields
                    Column(
                      children: [
                        // Email field
                        AuthTextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          labelText: 'Enter Your Email',
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Signup fields
                        if (_isSignUp) ...[
                          AuthTextField(
                            controller: _nameController,
                            labelText: 'Full Name',
                            prefixIcon: Icons.person_outline,
                            validator: _isSignUp
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            labelText: 'Phone Number (Optional)',
                            prefixIcon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _collegeController,
                            labelText: 'College/University (Optional)',
                            prefixIcon: Icons.school_outlined,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedYear,
                            decoration: InputDecoration(
                              labelText: 'Year (Optional)',
                              labelStyle: TextStyle(
                                  color:
                                      colorScheme.onSurface.withValues(alpha: 0.6)),
                              prefixIcon: Icon(Icons.calendar_today_outlined,
                                  color: colorScheme.primary),
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            dropdownColor: colorScheme.surface,
                            style: TextStyle(color: colorScheme.onSurface),
                            items:
                                ['1st Year', '2nd Year', '3rd Year', '4th Year']
                                    .map((year) => DropdownMenuItem(
                                          value: year,
                                          child: Text(year),
                                        ))
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _courseController,
                            labelText: 'Course/Department (Optional)',
                            prefixIcon: Icons.book_outlined,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Password field
                        AuthTextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          labelText: 'Enter Your Password',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (_isSignUp && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 8),

                    // Forgot password (only for login)
                    if (!_isSignUp)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ).animate().fadeIn(delay: 450.ms),
                    const SizedBox(height: 16),

                    // Login/Signup button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleEmailAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isSignUp ? 'Sign Up' : 'Log In',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: colorScheme.onSurface.withValues(alpha: 0.1))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or Continue with',
                            style: TextStyle(
                                color: colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                color: colorScheme.onSurface.withValues(alpha: 0.1))),
                      ],
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 24),

                    // Social login buttons
                    SocialLoginButtons(
                      isLoading: _isLoading,
                      onGoogleSignIn: _handleGoogleSignIn,
                      onFacebookSignIn: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Facebook login coming soon!',
                                style: TextStyle(
                                    color: colorScheme.onInverseSurface)),
                            backgroundColor: colorScheme.inverseSurface,
                          ),
                        );
                      },
                    )
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),

                    // Toggle signup/login
                    TextButton(
                      onPressed: () => setState(() {
                        _isSignUp = !_isSignUp;
                        _errorMessage = null;
                        if (!_isSignUp) {
                          _nameController.clear();
                          _phoneController.clear();
                          _collegeController.clear();
                          _courseController.clear();
                          _selectedYear = null;
                        }
                      }),
                      child: RichText(
                        text: TextSpan(
                          text: _isSignUp
                              ? 'Already have an account? '
                              : 'Don\'t have an account? ',
                          style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.6)),
                          children: [
                            TextSpan(
                              text: _isSignUp ? 'Log in' : 'Sign up',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
