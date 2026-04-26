import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../services/firestore_service.dart';
import '../../utils/page_transitions.dart';
import '../../utils/widgets.dart';
import '../../utils/user_data.dart';

class AuthMethodScreen extends StatefulWidget {
  const AuthMethodScreen({super.key});

  @override
  State<AuthMethodScreen> createState() => _AuthMethodScreenState();
}

class _AuthMethodScreenState extends State<AuthMethodScreen> {
  bool _isGoogleLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Gap(30),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.black,
                  iconSize: 28,
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
              ],
            ),
            Gap(20),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(
                    text: "Choose your ",
                    style: TextStyle(fontSize: 29),
                  ),
                  TextSpan(
                    text: "Signup",
                    style: const TextStyle(color: Colors.green, fontSize: 29),
                  ),
                  const TextSpan(text: " Method?"),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Select how you'd like to create your account",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            // Email/Password Option
            _buildAuthOption(
              context,
              icon: Icons.email,
              title: "Email & Password",
              subtitle: "Create account with email and password",
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageTransitions.slideAndFadeTransition(
                    const EmailPasswordScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Google Option
            _buildAuthOption(
              context,
              icon: Icons.g_mobiledata,
              title: "Google",
              subtitle: "Continue with Google account",
              onTap: _isGoogleLoading ? () {} : () async => _signInWithGoogle(),
            ),
            if (_isGoogleLoading) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.green),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        if (!mounted) return;
        _showErrorDialog(
          context,
          'Google sign-in failed: missing authentication token.',
        );
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      if (!mounted) return;

      final existingUserData = await FirestoreService.getUserData(
        userCredential.user!.uid,
      );
      if (existingUserData != null && existingUserData.isNotEmpty) {
        await FirebaseAuth.instance.signOut();
        await googleSignIn.signOut();
        if (!mounted) return;
        _showErrorDialog(
          context,
          'This Google email is already registered. Please log in instead.',
        );
        return;
      }

      signupData.email =
          FirebaseAuth.instance.currentUser?.email ?? googleUser.email;
      signupData.password = null;
      signupData.googleIdToken = null;
      signupData.googleAccessToken = null;
      signupData.isGoogleSignIn = true;

      // Only pre-fill the name when the user hasn't already entered one.
      if ((signupData.name == null || signupData.name!.trim().isEmpty) &&
          googleUser.displayName != null &&
          googleUser.displayName!.isNotEmpty) {
        signupData.name = googleUser.displayName!;
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/loading');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message =
          e.code == 'account-exists-with-different-credential'
              ? 'This email is already registered. Please log in instead.'
              : 'Google sign-in failed: ${e.message ?? e.code}';
      _showErrorDialog(
        context,
        message,
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(context, 'Google sign-in failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign-in Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuthOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.green, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class EmailPasswordScreen extends StatefulWidget {
  const EmailPasswordScreen({super.key});

  @override
  State<EmailPasswordScreen> createState() => _EmailPasswordScreenState();
}

class _EmailPasswordScreenState extends State<EmailPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasLowerCase = false;
  bool _hasUpperCase = false;
  bool _hasNumbers = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasNumbers = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Store email and password in signupData temporarily (NOT in Firebase Auth yet)
      signupData.email = email;
      signupData.password = password;
      signupData.isGoogleSignIn = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent to your inbox.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to email verification screen (email not yet in Firebase Auth)
        Navigator.pushReplacementNamed(
          context,
          '/email_verification',
          arguments: email,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!_hasUpperCase) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!_hasLowerCase) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!_hasNumbers) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Gap(30),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.black,
                    iconSize: 28,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
              Gap(20),
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Enter your email and password",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                onChanged: (value) {
                  _updatePasswordStrength(value);
                },
                validator: _validatePassword,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              // Password Strength Indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF0F0F0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password Requirements',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildPasswordRequirement('At least 8 characters', _hasMinLength),
                    const SizedBox(height: 10),
                    _buildPasswordRequirement('Uppercase letter (A-Z)', _hasUpperCase),
                    const SizedBox(height: 10),
                    _buildPasswordRequirement('Lowercase letter (a-z)', _hasLowerCase),
                    const SizedBox(height: 10),
                    _buildPasswordRequirement('Numbers (0-9)', _hasNumbers),
                    const SizedBox(height: 10),
                    _buildPasswordRequirement('Special character (!@#\$%^&*)', _hasSpecialChar, isOptional: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: _validateConfirmPassword,
                enabled: !_isLoading,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              // Sign in link
              Center(
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                  child: RichText(
                    text: const TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Sign in",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : NextButton(
                      height: 56,
                      label: 'Create Account',
                      onPressed: _createAccount,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String requirement, bool isMet, {bool isOptional = false}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isMet ? const Color(0xff13EC5B).withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isMet ? const Color(0xff13EC5B) : Colors.grey.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: isMet
              ? const Icon(Icons.check, size: 16, color: Color(0xff13EC5B))
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Text(
                requirement,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isMet ? const Color(0xFF1A1A1A) : Colors.grey[600],
                ),
              ),
              if (isOptional) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
