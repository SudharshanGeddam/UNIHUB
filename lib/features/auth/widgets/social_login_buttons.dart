import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onFacebookSignIn;

  const SocialLoginButtons({
    super.key,
    required this.isLoading,
    required this.onGoogleSignIn,
    required this.onFacebookSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onGoogleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(115, 63, 62, 62),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Image.asset(
              'assets/images/google.jpeg',
              height: 24,
            ),
            label: const Text(
              'Google',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onFacebookSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(115, 63, 62, 62),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Image.asset(
              'assets/images/facebook.jpeg',
              height: 24,
            ),
            label: const Text(
              'Facebook',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
