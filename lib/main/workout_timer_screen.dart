import 'dart:async';
import 'package:flutter/material.dart';

class WorkoutTimerScreen extends StatefulWidget {
  const WorkoutTimerScreen({super.key});

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  late int secondsRemaining;
  Timer? _timer;
  bool paused = false;

  @override
  void initState() {
    super.initState();
    // initial time: 2 minutes 20 seconds
    secondsRemaining = 2 * 60 + 20;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (paused) return;
      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        t.cancel();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout complete')));
      }
    });
  }

  void _togglePause() {
    setState(() => paused = !paused);
    // ensure timer is running in background to continue ticking when resumed
    if (!paused && (_timer == null || !_timer!.isActive)) {
      _startTimer();
    }
  }

  String _formatTime(int totalSec) {
    final minutes = totalSec ~/ 60;
    final seconds = totalSec % 60;
    return '${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jumping Jacks")),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            _formatTime(secondsRemaining),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Image.asset(
              "assets/workout.png", // replace with your image asset or keep as placeholder
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: paused ? Colors.green : Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _togglePause,
              child: Text(paused ? "Resume Workout" : "Pause Workout"),
            ),
          ),
        ],
      ),
    );
  }
}
