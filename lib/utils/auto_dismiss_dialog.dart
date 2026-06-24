import 'package:flutter/material.dart';

class AutoDismissDialog extends StatefulWidget {
  final String title;
  final String message;
  final Duration dismissDuration;

  const AutoDismissDialog({
    super.key,
    required this.title,
    required this.message,
    this.dismissDuration = const Duration(seconds: 5),
  });

  @override
  State<AutoDismissDialog> createState() => _AutoDismissDialogState();
}

class _AutoDismissDialogState extends State<AutoDismissDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.dismissDuration,
      vsync: this,
    )..forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isUserInteracting) {
        _dismissDialog();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismissDialog() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onDialogTouched() {
    setState(() {
      _isUserInteracting = true;
    });
    _animationController.stop();
  }

  void _onDialogReleased() {
    if (!_isUserInteracting) return;

    setState(() {
      _isUserInteracting = false;
    });

    // Resume the animation after user releases
    if (_animationController.isAnimating == false) {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GestureDetector(
        onTapDown: (_) => _onDialogTouched(),
        onTapUp: (_) => _onDialogReleased(),
        onTapCancel: _onDialogReleased,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Progress indicator showing time remaining
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 1 - _animationController.value,
                  minHeight: 3,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(
                    _isUserInteracting ? scheme.primary : scheme.secondary,
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

// Helper function to show the auto-dismiss dialog
void showAutoDismissDialog(
  BuildContext context, {
  required String title,
  required String message,
  Duration dismissDuration = const Duration(seconds: 5),
}) {
  showDialog(
    context: context,
    barrierDismissible: true, // Click outside to dismiss
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (context) => AutoDismissDialog(
      title: title,
      message: message,
      dismissDuration: dismissDuration,
    ),
  );
}
