import 'package:flutter/material.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureRePassword = true;

  bool hasNumber = false;
  bool hasUppercase = false;
  bool hasSpecial = false;
  bool hasMinLength = false;

  void checkPassword(String value) {
    setState(() {
      hasMinLength = value.length >= 8;
      hasNumber = value.contains(RegExp(r'[0-9]'));
      hasUppercase = value.contains(RegExp(r'[A-Z]'));
      hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  double getStrength() {
    int strength = 0;
    if (hasMinLength) strength++;
    if (hasNumber) strength++;
    if (hasUppercase) strength++;
    if (hasSpecial) strength++;
    return strength / 4;
  }

  String getStrengthLabel() {
    double strength = getStrength();
    if (strength <= 0.5) return "Weak";
    if (strength < 1) return "Medium";
    return "Strong";
  }

  Color getStrengthColor() {
    double strength = getStrength();
    if (strength <= 0.5) return Colors.red;
    if (strength < 1) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // Ensure the content fills available height so Spacer() pushes the button down on large screens
            minHeight: MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Secure your ",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    text: "Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please enter a strong password protect your fitness data",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                _passwordField("New Password", _passwordController, _obscurePassword, () {
                  setState(() => _obscurePassword = !_obscurePassword);
                }),
                const SizedBox(height: 8),
                _passwordStrengthBar(),
                const SizedBox(height: 16),
                _passwordField("Re-enter Password", _rePasswordController, _obscureRePassword, () {
                  setState(() => _obscureRePassword = !_obscureRePassword);
                }),
                const Spacer(),
                _greenButton("Reset Password", () {
                  // Handle reset password
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField(String hint, TextEditingController controller, bool obscure, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: (value) => checkPassword(value),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _passwordStrengthBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: getStrength(),
          color: getStrengthColor(),
          backgroundColor: Colors.grey[300],
          minHeight: 6,
        ),
        const SizedBox(height: 4),
        Text(
          "Strength: ${getStrengthLabel()}",
          style: TextStyle(color: getStrengthColor()),
        ),
        const SizedBox(height: 8),
        _passwordRules(),
      ],
    );
  }

  Widget _passwordRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ruleText("Min 8 characters", hasMinLength),
        _ruleText("At least 1 number", hasNumber),
        _ruleText("1 special character", hasSpecial),
        _ruleText("1 uppercase letter", hasUppercase),
      ],
    );
  }

  Widget _ruleText(String text, bool passed) {
    return Row(
      children: [
        Icon(passed ? Icons.check_circle : Icons.cancel, color: passed ? Colors.green : Colors.red, size: 18),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  Widget _greenButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
