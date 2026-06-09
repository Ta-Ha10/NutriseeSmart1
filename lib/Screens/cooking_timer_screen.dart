import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'recipe_feedback.dart';
import '../services/ai_chat_service.dart';

class CookingTimerScreen extends StatefulWidget {
  final String recipeName;
  final List<Map<String, String>> ingredients;
  final List<String> instructions;
  final int prepTime;
  final String? imageUrl;
  final String? mealType;
  final String? recipeId;

  const CookingTimerScreen({
    super.key,
    required this.recipeName,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    this.imageUrl,
    this.mealType,
    this.recipeId,
  });

  @override
  State<CookingTimerScreen> createState() => _CookingTimerScreenState();
}

class _CookingTimerScreenState extends State<CookingTimerScreen> {
  late Timer _timer;
  int _remainingSeconds = 0;
  int _currentStepIndex = 0;
  List<bool> _completedSteps = [];
  bool _isRunning = false;
  List<String> _aiGeneratedSteps = [];
  bool _isLoadingSteps = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = (widget.prepTime * 60).toInt();
    _completedSteps = List.filled(widget.instructions.length, false);
    _fetchRecipeStepsFromAI();
  }

  Future<void> _fetchRecipeStepsFromAI() async {
    setState(() => _isLoadingSteps = true);
    try {
      final aiService = AIChatService();
      final response = await aiService.getPreparationSteps(
        recipeName: widget.recipeName,
        ingredients: widget.ingredients,
        language: 'en',
      );

      // Parse the response
      _parseAIResponse(response);
    } catch (e) {
      debugPrint('Error fetching recipe steps: $e');
      // Fall back to provided instructions
      setState(() {
        _aiGeneratedSteps = widget.instructions;
        _isLoadingSteps = false;
      });
    }
  }

  void _parseAIResponse(String response) {
    try {
      // Extract instructions
      final instructionsMatch = RegExp(
        r'INSTRUCTIONS:\n([\s\S]+?)(?:\n\n|$)',
      ).firstMatch(response);
      if (instructionsMatch != null) {
        final instructionsText = instructionsMatch.group(1) ?? '';
        _aiGeneratedSteps = instructionsText
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
            .toList();
      } else {
        _aiGeneratedSteps = widget.instructions;
      }

      setState(() {
        _completedSteps = List.filled(_aiGeneratedSteps.length, false);
        _isLoadingSteps = false;
      });
    } catch (e) {
      debugPrint('Error parsing AI response: $e');
      setState(() {
        _aiGeneratedSteps = widget.instructions;
        _isLoadingSteps = false;
      });
    }
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer.cancel();
            _isRunning = false;
            _showCompletionDialog();
          }
        });
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF13EC5B),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Cooking Complete!',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF243447),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.recipeName} is ready to serve',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13EC5B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => RecipeFeedbackScreen(
                          recipeName: widget.recipeName,
                          recipeId: widget.recipeId,
                        ),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  child: Text(
                    'Done',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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

  void _markStepComplete(int index) {
    setState(() {
      _completedSteps[index] = !_completedSteps[index];
    });
  }

  void _nextStep() {
    if (_currentStepIndex < _aiGeneratedSteps.length - 1) {
      setState(() => _currentStepIndex++);
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() => _currentStepIndex--);
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    if (_isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completedSteps.where((c) => c).length;
    final progress = _completedSteps.isEmpty
        ? 0.0
        : completedCount / _completedSteps.length.toDouble();

    return WillPopScope(
      onWillPop: () async {
        if (_isRunning) {
          _timer.cancel();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF2EDE9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () {
              if (_isRunning) {
                _timer.cancel();
              }
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Cooking Guide',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Recipe Image & Name
              if (widget.imageUrl != null)
                Image.network(
                  widget.imageUrl!,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 240,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 64),
                    );
                  },
                )
              else
                Container(
                  height: 240,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 64),
                ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipeName,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF243447),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Ingredients
                      Text(
                        'Ingredients',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5F6B78),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.ingredients.map((ing) {
                        final qty = ing['quantity'] ?? '';
                        final name = ing['name'] ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF13EC5B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '$qty $name'.trim(),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF5F6B78),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timer Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF13EC5B), Color(0xFF49B44E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Prep Time',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatTime(_remainingSeconds),
                            style: GoogleFonts.inter(
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF13EC5B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _toggleTimer,
                              icon: Icon(
                                _isRunning ? Icons.pause : Icons.play_arrow,
                                size: 24,
                              ),
                              label: Text(
                                _isRunning ? 'Pause' : 'Start',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Loading AI Steps
                    if (_isLoadingSteps)
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF13EC5B),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Generating recipe steps...',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Steps Progress
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Step ${_currentStepIndex + 1} of ${_aiGeneratedSteps.length}',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF243447),
                                ),
                              ),
                              Text(
                                '$completedCount / ${_aiGeneratedSteps.length} done',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF13EC5B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Current Step
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF13EC5B),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF13EC5B),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${_currentStepIndex + 1}',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Step ${_currentStepIndex + 1}',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF243447),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _aiGeneratedSteps[_currentStepIndex],
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: const Color(0xFF5F6B78),
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child:
                                      _currentStepIndex ==
                                          _aiGeneratedSteps.length - 1
                                      ? ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF13EC5B,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: _showCompletionDialog,
                                          icon: const Icon(Icons.check_circle),
                                          label: Text(
                                            'End Recipe',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      : ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                _completedSteps[_currentStepIndex]
                                                ? const Color(0xFF13EC5B)
                                                : Colors.grey[300],
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () => _markStepComplete(
                                            _currentStepIndex,
                                          ),
                                          icon: Icon(
                                            _completedSteps[_currentStepIndex]
                                                ? Icons.check_circle
                                                : Icons.check_circle_outline,
                                          ),
                                          label: Text(
                                            _completedSteps[_currentStepIndex]
                                                ? 'Done'
                                                : 'Mark Done',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Static Navigation Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _currentStepIndex > 0
                                        ? const Color(0xFF243447)
                                        : Colors.grey[400],
                                    side: BorderSide(
                                      color: _currentStepIndex > 0
                                          ? const Color(0xFF243447)
                                          : Colors.grey[300]!,
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: _currentStepIndex > 0
                                      ? _previousStep
                                      : null,
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 14,
                                  ),
                                  label: Text(
                                    'Previous',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _currentStepIndex <
                                            _aiGeneratedSteps.length - 1
                                        ? const Color(0xFF13EC5B)
                                        : Colors.grey[300],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed:
                                      _currentStepIndex <
                                          _aiGeneratedSteps.length - 1
                                      ? _nextStep
                                      : null,
                                  icon: const Icon(Icons.arrow_forward),
                                  label: Text(
                                    'Next',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: 32),
                    // All Steps Checklist
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All Steps',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF243447),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_aiGeneratedSteps.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _markStepComplete(index),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: _completedSteps[index]
                                            ? const Color(0xFF13EC5B)
                                            : Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: _completedSteps[index]
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(
                                          () => _currentStepIndex = index,
                                        );
                                      },
                                      child: Text(
                                        'Step ${index + 1}',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: _currentStepIndex == index
                                              ? const Color(0xFF13EC5B)
                                              : Colors.grey[600],
                                          fontWeight: _currentStepIndex == index
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          decoration: _completedSteps[index]
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
