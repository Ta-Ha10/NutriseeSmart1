import 'package:flutter/material.dart';
import 'new_password_screen.dart';

class ResetPasswordPhone extends StatelessWidget {
  const ResetPasswordPhone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reset Password",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text("Phone Number"),
            const SizedBox(height: 6),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "0123456789",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const Spacer(),
            _greenButton("Send Reset Code", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewPasswordScreen(),
                ),
              );
            }),
          ],
        ),
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
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
