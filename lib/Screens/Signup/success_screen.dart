import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../utils/user_data.dart';

class SuccessScreen extends StatefulWidget {
  final UserData userData;

  const SuccessScreen({super.key, required this.userData});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _isSaving = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _finishSignup();
  }

  Future<void> _finishSignup() async {
    try {
      await FirestoreService.saveUserData(widget.userData);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not complete signup: $error';
        _isSaving = false;
      });
      return;
    }

    widget.userData.clearSignupState();
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final message = _errorMessage ??
        (_isSaving
            ? 'Finishing your signup and saving your profile.'
            : 'Success! You are being redirected to the home page.');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: _errorMessage == null ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _errorMessage == null ? Icons.check : Icons.error_outline,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            if (_isSaving && _errorMessage == null) ...[
              const CircularProgressIndicator(color: Colors.green),
              const SizedBox(height: 24),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/auth_method');
                },
                child: const Text('Back'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
