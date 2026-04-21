import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add,
                  size: 60,
                  color: Colors.green,
                ),
              ),
              const Gap(40),

              // Title
              Text(
                'Welcome to NutriSeseSmart',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),

              // Subtitle
              Text(
                'Let\'s start by knowing your name',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const Gap(48),

              // Name Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: GoogleFonts.inter(color: Colors.black38),
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              const Gap(48),
              _isNameValid
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
            ],
          ),
        ),
      ),
    );
  }
}
