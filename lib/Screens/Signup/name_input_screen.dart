import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_locale.dart';
import '../../utils/page_transitions.dart';
import '../../utils/user_data.dart';
import '../../utils/widgets.dart';
import 'birth_screen.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill name if available from Google Sign-In
    if (signupData.name != null && signupData.name!.isNotEmpty) {
      _nameController.text = signupData.name!;
      _isNameValid = true;
    }
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _isNameValid = _nameController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2EDE9),
      body: SignupStepBody(
        activeIndex: 0,
        centerTitle: true,
        title: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppLocaleController.isArabic() ? 'أدخل ' : 'Enter your ',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextSpan(
                  text: AppLocaleController.isArabic() ? 'اسمك؟' : 'name ?',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff13EC5B),
                  ),
                ),
              ],
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: const AssetImage('assets/Photoes/Profile Photo.png'),
                ),
                const Gap(20),
                Text(
                  AppLocaleController.isArabic()
                      ? 'لنبدأ بمعرفة اسمك'
                      : 'Let\'s start by knowing your name',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const Gap(30),
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: AppLocaleController.isArabic()
                          ? 'أدخل اسمك'
                          : 'Enter your name',
                      hintStyle: GoogleFonts.inter(color: Colors.black38),
                      prefixIcon: const Icon(Icons.person, color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomAction: _isNameValid
            ? NextButton(
                onPressed: () {
                  signupData.name = _nameController.text.trim();
                  Navigator.push(
                    context,
                    CustomPageTransitions.slideAndFadeTransition(
                      const BirthScreen(),
                    ),
                  );
                },
              )
            : Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    'Enter your name to continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
