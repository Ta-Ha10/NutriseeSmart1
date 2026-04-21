import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../utils/page_transitions.dart';
import '../../utils/user_data.dart';
import 'auth_method_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  static const int _initialCooldownSeconds = 30;
  int _remainingSeconds = _initialCooldownSeconds;
  Timer? _timer;
  bool _isSending = false;
  bool _isChecking = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _sendVerificationEmail(); // Send email on screen load
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _initialCooldownSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
      } else {
        setState(() {
          _remainingSeconds -= 1;
        });
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isSending = true;
      _statusMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found.');
      }

      // Resend verification email
      await user.sendEmailVerification();
      _startResendTimer();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email resent. Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _statusMessage = 'Verification email resent. Please click the link in your email.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Unable to resend. Please try again: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      // Create Firebase Auth account and send verification email
      if (signupData.email != null && signupData.password != null) {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: signupData.email!,
          password: signupData.password!,
        );

        // Send verification email
        await userCredential.user?.sendEmailVerification();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email sent! Check your inbox.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = _getErrorMessage(e.code);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _checkIfVerified() async {
    setState(() {
      _isChecking = true;
      _statusMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found.');
      }

      // Reload user to check if email is verified
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/loading');
        return;
      }

      setState(() {
        _statusMessage = 'Email not verified yet. Please check your inbox and click the verification link.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'An error occurred: $errorCode';
    }
  }

  void _editEmail() {
    Navigator.pushReplacement(
      context,
      CustomPageTransitions.slideAndFadeTransition(const EmailPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resendLabel = _remainingSeconds > 0
        ? 'Resend available in $_remainingSeconds s'
        : 'Resend verification email';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gap(30),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.black,
                    iconSize: 28,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
              Gap(20),
              const Text(
                'Verify Your Email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 12),
              Text(
                'A verification link has been sent to ${widget.email}. Please open your email and verify your account before continuing.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 28),
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isChecking ? null : _checkIfVerified,
                child: _isChecking
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('I have verified my email'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _remainingSeconds == 0 && !_isSending ? _resendVerificationEmail : null,
                child: Text(
                  resendLabel,
                  style: TextStyle(
                    color: _remainingSeconds == 0 && !_isSending ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: _editEmail,
                child: const Text(
                  'Edit email address',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              const Spacer(),
              Text(
                'Tip: If you do not see the email, check your spam folder or use the resend button once the timer ends.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
