import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/recommendation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_locale.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late Future<List<String>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _recommendationsFuture = user != null
        ? RecommendationService.getRecommendedRecipes(user.uid)
        : Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
        final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.recommendedForYou(context),
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: FutureBuilder<List<String>>(
        future: _recommendationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noRecommendations(context),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    '${AppLocaleController.isArabic() ? 'الوصفة' : 'Recipe'} ${AppLocaleController.formatNumber(index + 1)}',
                  ),
                  subtitle: Text(
                    AppLocaleController.isArabic()
                        ? 'مقترح بناءً على تفضيلاتك'
                        : 'Recommended based on your preferences',
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to recipe details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

