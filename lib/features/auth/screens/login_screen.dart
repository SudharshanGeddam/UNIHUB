import 'package:flutter/material.dart';
import 'package:unihub/features/home/screens/home_screen.dart';
import 'package:unihub/services/auth_service.dart';
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (mounted && result == null) {
        // User cancelled - don't show error
        setState(() => _errorMessage = null);
      }
    } catch (e) {
      String errorMsg = e.toString();
      // Provide helpful message for common OAuth configuration issues
      if (errorMsg.contains('oauth_client') ||
          errorMsg.contains('ID token is null') ||
          errorMsg.contains('10:')) {
        errorMsg =
            'Google Sign-In not configured. Please add SHA-1 fingerprint to Firebase Console:\nDA:F5:7D:DB:1C:71:74:48:D8:EE:6D:30:DD:17:BF:6F:5B:65:1D:4F';
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
          const SnackBar(
            content: Text('Password reset email sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(179, 63, 62, 62),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            // Form
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Error message
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),

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

                        // Name field (only for sign up)
                        if (_isSignUp)
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
                        if (_isSignUp) const SizedBox(height: 16),

                        // Phone field (only for sign up)
                        if (_isSignUp)
                          AuthTextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            labelText: 'Phone Number (Optional)',
                            prefixIcon: Icons.phone_outlined,
                          ),
                        if (_isSignUp) const SizedBox(height: 16),

                        // College field (only for sign up)
                        if (_isSignUp)
                          AuthTextField(
                            controller: _collegeController,
                            labelText: 'College/University (Optional)',
                            prefixIcon: Icons.school_outlined,
                          ),
                        if (_isSignUp) const SizedBox(height: 16),

                        // Year dropdown (only for sign up)
                        if (_isSignUp)
                          DropdownButtonFormField<String>(
                            initialValue: _selectedYear,
                            decoration: InputDecoration(
                              labelText: 'Year (Optional)',
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide:
                                    const BorderSide(color: Colors.white54),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                            ),
                            dropdownColor: const Color(0xFF0A022E),
                            style: const TextStyle(color: Colors.white),
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
                        if (_isSignUp) const SizedBox(height: 16),

                        // Course field (only for sign up)
                        if (_isSignUp)
                          AuthTextField(
                            controller: _courseController,
                            labelText: 'Course/Department (Optional)',
                            prefixIcon: Icons.book_outlined,
                          ),
                        if (_isSignUp) const SizedBox(height: 16),

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
                              color: Colors.white,
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
                        const SizedBox(height: 8),

                        // Forgot password (only for login)
                        if (!_isSignUp)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Login/Signup button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleEmailAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 6, 40, 229),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isSignUp ? 'Sign Up' : 'Log In',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Divider
                        const Text(
                          'or Continue with',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),

                        // Social login buttons
                        SocialLoginButtons(
                          isLoading: _isLoading,
                          onGoogleSignIn: _handleGoogleSignIn,
                          onFacebookSignIn: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Facebook login coming soon!'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Toggle signup/login
                        TextButton(
                          onPressed: () => setState(() {
                            _isSignUp = !_isSignUp;
                            _errorMessage = null;
                            // Clear additional fields when switching
                            if (!_isSignUp) {
                              _nameController.clear();
                              _phoneController.clear();
                              _collegeController.clear();
                              _courseController.clear();
                              _selectedYear = null;
                            }
                          }),
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Log in'
                                : 'Don\'t have an account? Sign up',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
