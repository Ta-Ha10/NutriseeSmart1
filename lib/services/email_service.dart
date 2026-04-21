import 'package:firebase_auth/firebase_auth.dart';

class EmailService {
  /// Send verification email via Firebase Auth
  static Future<void> sendVerificationEmail(User? user) async {
    try {
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Verification email sent to ${user.email}');
      }
    } catch (e) {
      print('Error sending verification email: $e');
      throw Exception('Failed to send verification email: $e');
    }
  }
}
