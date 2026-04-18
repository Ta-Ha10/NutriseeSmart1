import 'package:flutter/material.dart';
import 'reset_password_phone.dart';

import 'new_password_screen.dart';

class ResetPasswordEmail extends StatelessWidget {
  const ResetPasswordEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Reset Password",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Don't worry, it happens. Enter your details below and we will send you a code to reset it",
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  _tab("Email", true),
                  _tab(
                    "Phone",
                    false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ResetPasswordPhone(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text("Email Address"),
              const SizedBox(height: 6),
              _inputField("user@example.com"),

              const SizedBox(height: 24),
              _greenButton("Send Reset Code", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String text, bool active, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? Colors.green.withOpacity(0.1) : null,
            border: Border.all(color: Colors.green),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: active ? Colors.green : Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _greenButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
