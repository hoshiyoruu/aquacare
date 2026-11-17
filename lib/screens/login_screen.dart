import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Custom Color Palette for Aquacare+
  static const Color primaryBlue = Color(0xFF0077B6); // Ocean Blue
  static const Color darkBlue = Color(0xFF023E8A);    // Deep Navy
  static const Color aquaLight = Color(0xFFE0F7FA);   // Soft Aqua Accent

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final userCredential = await _authService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (userCredential == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in failed or was canceled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO PLACEHOLDER
                // Replace the Icon below with your Image.asset('assets/logo.png') later
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: aquaLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.water_drop_rounded,
                      size: 60,
                      color: primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // APP NAME
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Aquacare',
                        style: TextStyle(color: darkBlue),
                      ),
                      TextSpan(
                        text: '+',
                        style: TextStyle(color: primaryBlue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // SUBTITLE
                const Text(
                  'Smart Water Quality & IoT Monitoring',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 50),

                // SIGN IN BUTTON / LOADING
                _isLoading
                    ? const CircularProgressIndicator(color: primaryBlue)
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                        ),
                        onPressed: _handleGoogleSignIn,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google Icon fallback
                            Image.asset(
                              'assets/google_logo.png',
                              height: 22,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.login, color: primaryBlue),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 32),

                // FOOTER
                Text(
                  'Powered by ThingsBoard',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}