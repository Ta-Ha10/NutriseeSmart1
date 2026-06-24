import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../l10n/app_locale.dart';
import '../Signup/intro_carousel_screen.dart';
import 'reset_password_email.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = AppLocaleController.isArabic()
            ? 'ظٹط±ط¬ظ‰ ظ…ظ„ط، ط¬ظ…ظٹط¹ ط§ظ„ط­ظ‚ظˆظ„'
            : 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final user = userCredential.user;
      if (user != null) {
        if (user.email != null && !user.emailVerified) {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            setState(() {
              _errorMessage = AppLocaleController.isArabic()
                  ? 'ط§ظ„ط¨ط±ظٹط¯ ط§ظ„ط¥ظ„ظƒطھط±ظˆظ†ظٹ ط؛ظٹط± ظ…ظپط¹ظ„. ظٹط±ط¬ظ‰ ط§ظ„طھط­ظ‚ظ‚ ظ…ظ† ط¨ط±ظٹط¯ظƒ ط§ظ„ط¥ظ„ظƒطھط±ظˆظ†ظٹ ظˆطھط£ظƒظٹط¯ ط§ظ„ط­ط³ط§ط¨ ظ‚ط¨ظ„ طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„.'
                  : 'Email not verified. Please check your email and verify your account before logging in.';
            });
          }
          return;
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppLocaleController.isArabic()
            ? 'ط­ط¯ط« ط®ط·ط£ ط؛ظٹط± ظ…طھظˆظ‚ط¹. ظٹط±ط¬ظ‰ ط§ظ„ظ…ط­ط§ظˆظ„ط© ظ…ط±ط© ط£ط®ط±ظ‰.'
            : 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null && user.email != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          setState(() {
            _errorMessage = AppLocaleController.isArabic()
                ? 'ط§ظ„ط¨ط±ظٹط¯ ط§ظ„ط¥ظ„ظƒطھط±ظˆظ†ظٹ ط؛ظٹط± ظ…ظپط¹ظ„. ظٹط±ط¬ظ‰ طھط£ظƒظٹط¯ ط§ظ„ط¨ط±ظٹط¯ ط§ظ„ط¥ظ„ظƒطھط±ظˆظ†ظٹ ظ‚ط¨ظ„ طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„.'
                : 'Email not verified. Please verify your email before logging in.';
          });
        }
        return;
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = AppLocaleController.isArabic()
            ? 'ظپط´ظ„ طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„ ط¹ط¨ط± Google: ${e.message}'
            : 'Google sign-in failed: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppLocaleController.isArabic()
            ? 'ظپط´ظ„ طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„ ط¹ط¨ط± Google. ظٹط±ط¬ظ‰ ط§ظ„ظ…ط­ط§ظˆظ„ط© ظ…ط±ط© ط£ط®ط±ظ‰.'
            : 'Google sign-in failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return AppLocaleController.isArabic()
            ? 'ظ„ط§ ظٹظˆط¬ط¯ ط­ط³ط§ط¨ ط¨ظ‡ط°ط§ ط§ظ„ط¨ط±ظٹط¯ ط§ظ„ط¥ظ„ظƒطھط±ظˆظ†ظٹ.'
            : 'No account found with this email address.';
      case 'wrong-password':
        return AppLocaleController.isArabic()
            ? 'ظƒظ„ظ…ط© ط§ظ„ظ…ط±ظˆط± ط؛ظٹط± طµط­ظٹط­ط©.'
            : 'Incorrect password.';
      case 'invalid-email':
        return AppLocaleController.isArabic()
            ? 'ظٹط±ط¬ظ‰ ط¥ط¯ط®ط§ظ„ ط¨ط±ظٹط¯ ط¥ظ„ظƒطھط±ظˆظ†ظٹ طµط§ظ„ط­.'
            : 'Please enter a valid email address.';
      case 'user-disabled':
        return AppLocaleController.isArabic()
            ? 'طھظ… طھط¹ط·ظٹظ„ ظ‡ط°ط§ ط§ظ„ط­ط³ط§ط¨.'
            : 'This account has been disabled.';
      case 'too-many-requests':
        return AppLocaleController.isArabic()
            ? 'ط¹ط¯ط¯ ظƒط¨ظٹط± ط¬ط¯ظ‹ط§ ظ…ظ† ط§ظ„ظ…ط­ط§ظˆظ„ط§طھ ط§ظ„ظپط§ط´ظ„ط©. ط­ط§ظˆظ„ ظ…ط±ط© ط£ط®ط±ظ‰ ظ„ط§ط­ظ‚ظ‹ط§.'
            : 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return AppLocaleController.isArabic()
            ? 'ط®ط·ط£ ظپظٹ ط§ظ„ط´ط¨ظƒط©. ظٹط±ط¬ظ‰ ط§ظ„طھط­ظ‚ظ‚ ظ…ظ† ط§طھطµط§ظ„ ط§ظ„ط¥ظ†طھط±ظ†طھ.'
            : 'Network error. Please check your internet connection.';
      default:
        return AppLocaleController.isArabic()
            ? 'ظپط´ظ„ طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„. ظٹط±ط¬ظ‰ ط§ظ„ظ…ط­ط§ظˆظ„ط© ظ…ط±ط© ط£ط®ط±ظ‰.'
            : 'Login failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: AppLocaleController.isArabic()
                        ? 'تغيير اللغة'
                        : 'Change language',
                    onPressed: () => AppLocaleController.setArabicEnabled(
                      !AppLocaleController.isArabic(),
                    ),
                    icon: const Icon(Icons.language),
                  ),
                ],
              ),

              /// ًں”° LOGO + APP NAME
              Center(
                child: Column(
                  children: [
                    Gap(60),
                    Hero(
                      tag: 'app-logo',
                      child: Image.asset('assets/G_Logo.png', height: 150),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// ًں‘‹ Welcome Text
              RichText(
                text: TextSpan(
                  text: AppLocaleController.isArabic()
                      ? 'ظ…ط±ط­ط¨ظ‹ط§ ط¨ط¹ظˆط¯طھظƒطŒ '
                      : 'Welcome Back, ',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: AppLocaleController.isArabic() ? 'ط±ظٹط§ط¶ظٹ' : 'Athlete',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              Text(
                AppLocaleController.isArabic()
                    ? 'ط³ط¬ظ‘ظ„ ط§ظ„ط¯ط®ظˆظ„ ظ„طھطھط¨ط¹ طھظ‚ط¯ظ…ظƒ'
                    : 'Sign in to track your progress',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              _inputField(
                AppLocaleController.isArabic() ? 'ط§ظ„ط¨ط±ظٹط¯ ط§ظ„ط¥ظ„ظƒطھط±ظˆظ†ظٹ' : 'Email',
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              _inputField(
                AppLocaleController.isArabic() ? 'ظƒظ„ظ…ط© ط§ظ„ظ…ط±ظˆط±' : 'Password',
                isPassword: true,
                controller: _passwordController,
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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResetPasswordEmail(),
                      ),
                    );
                  },
                  child: Text(
                    AppLocaleController.isArabic()
                        ? 'ظ‡ظ„ ظ†ط³ظٹطھ ظƒظ„ظ…ط© ط§ظ„ظ…ط±ظˆط±طں'
                        : 'Forget Password ?',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              _isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : _greenButton(
                      AppLocaleController.isArabic() ? 'طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„' : 'Log In',
                      _signIn,
                    ),

              const SizedBox(height: 20),

              /// ًں”µ Google Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: Text(
                    AppLocaleController.isArabic()
                        ? 'طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„ ط¹ط¨ط± Google'
                        : 'Sign in with Google',
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// ًں”— Sign Up
              Center(
                child: RichText(
                  text: TextSpan(
                    text: AppLocaleController.isArabic() ? 'ليس لديك حساب؟ ' : "Don't have an account? ",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    children: [
                      TextSpan(
                        text: AppLocaleController.isArabic() ? 'إنشاء حساب' : 'Sign up',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const IntroCarouselScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: !_isLoading,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: isPassword ? const Icon(Icons.visibility_outlined) : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _greenButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}



