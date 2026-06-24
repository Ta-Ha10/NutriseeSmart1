import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../l10n/app_locale.dart';
import 'name_input_screen.dart';

class IntroCarouselScreen extends StatefulWidget {
  const IntroCarouselScreen({super.key});

  @override
  State<IntroCarouselScreen> createState() => _IntroCarouselScreenState();
}

class _IntroCarouselScreenState extends State<IntroCarouselScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<IntroPage> introPages = [
    IntroPage(
      imagePath: 'assets/intro photes/first intro.png',
      title: 'TAILORED NUTRITION',
      description:
          'Nutrisee Smart uses AI to analyze your preferences and needs, crafting personalized meal plans that fit your diet (Vegan, Keto, Balanced).',
    ),
    IntroPage(
      imagePath: 'assets/intro photes/second intro.png',
      title: 'SMART WORKOUTS',
      description:
          'Achieve your fitness goals with adaptive workout routines that evolve as you progress, whether at home or in the gym.',
    ),
    IntroPage(
      imagePath: 'assets/intro photes/third intro.png',
      title: 'EMPOWERED HEALTH',
      description:
          'Unlock a healthier, more vibrant you. Monitor your holistic progress, celebrate milestones, and sustain a balanced lifestyle with guidance from Nutrisee Smart.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2EDE9),
      body: SafeArea(
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
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
                    color: Colors.black87,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            // PageView for carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: introPages.length,
                itemBuilder: (context, index) {
                  return IntroPageWidget(page: introPages[index]);
                },
              ),
            ),
            // Dots indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  introPages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Color(0xff13EC5B)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  if (_currentPage < introPages.length - 1)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff13EC5B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff13EC5B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NameInputScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'GET STARTED →',
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
          ],
        ),
      ),
    );
  }
}

class IntroPage {
  final String imagePath;
  final String title;
  final String description;

  IntroPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class IntroPageWidget extends StatelessWidget {
  final IntroPage page;

  const IntroPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          Expanded(child: Image.asset(page.imagePath, fit: BoxFit.contain)),
          const Gap(24),
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
