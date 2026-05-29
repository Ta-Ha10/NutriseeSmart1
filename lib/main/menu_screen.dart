import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutriseesmart1/main/profile_page.dart';
import 'package:nutriseesmart1/main/setting.dart';
import 'package:nutriseesmart1/main/feedback.dart';

class MenuScreen extends StatelessWidget {
  final String? userName;
  final String? userProfileImage;
  final VoidCallback? onClose;

  const MenuScreen({
    super.key,
    this.userName = 'Athlete',
    this.userProfileImage = 'assets/Photoes/Profile Photo.png',
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xff13EC5B);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(34),
        bottomRight: Radius.circular(34),
      ),
      child: SizedBox.expand(
        child: Container(
          color: const Color(0xFFF6F8F6),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Close button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 28),
                                onPressed: onClose ?? () {},
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Profile
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: green, width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 42,
                                    backgroundImage: AssetImage(
                                      userProfileImage!,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  userName ?? 'Athlete',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Menu Items
                            _item(
                              context,
                              Icons.person_outline,
                              "Profile",
                              green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                                onClose?.call();
                              },
                            ),
                            const SizedBox(height: 14),
                            _item(
                              context,
                              Icons.settings_outlined,
                              "Setting",
                              green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsScreen(),
                                  ),
                                );
                                onClose?.call();
                              },
                            ),
                            const SizedBox(height: 14),
                            _item(
                              context,
                              Icons.feedback_outlined,
                              "Feedback",
                              green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FeedbackScreen(),
                                  ),
                                );
                                onClose?.call();
                              },
                            ),
                            const SizedBox(height: 14),
                            _item(
                              context,
                              Icons.favorite_outline,
                              "Favourite",
                              green,
                            ),

                            const Spacer(),

                            // Logout
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: () => _logout(context),
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    Color green, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: green, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: green),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: green),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
