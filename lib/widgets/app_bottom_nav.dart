import 'package:flutter/material.dart';

import '../Screens/Signup/meals_screen.dart';
import '../Screens/daily_nutrition_summary_screen.dart';
import '../Screens/nutrition_history_screen.dart';
import '../main/home_screen.dart';
import '../main/setting.dart';

class AppBottomNav extends StatefulWidget {
  final int selectedIndex;

  const AppBottomNav({super.key, this.selectedIndex = 2});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  static const Color _activeColor = Color(0xFF49B44E);
  static const Color _inactiveColor = Color(0xFFD9D9D9);

  late int _selectedIndex;

  final List<_BottomNavItem> _items = const [
    _BottomNavItem(
      icon: Icons.restaurant_menu_rounded,
      label: 'Meal',
      routeName: '/meal',
    ),
    _BottomNavItem(icon: Icons.book_outlined, label: 'Log', routeName: '/logs'),
    _BottomNavItem(
      icon: Icons.cottage_outlined,
      label: 'Home',
      routeName: '/home',
    ),
    _BottomNavItem(
      icon: Icons.query_stats_outlined,
      label: 'Stats',
      routeName: '/stats',
    ),
    _BottomNavItem(
      icon: Icons.settings_suggest_outlined,
      label: 'Settings',
      routeName: '/settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex.clamp(0, _items.length - 1);
  }

  @override
  void didUpdateWidget(covariant AppBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _selectedIndex = widget.selectedIndex.clamp(0, _items.length - 1);
    }
  }

  void _selectItem(int index) {
    final routeName = _items[index].routeName;
    if (routeName == null) return;

    setState(() => _selectedIndex = index);
    Navigator.of(context).pushReplacement(_buildRoute(routeName));
  }

  PageRouteBuilder<void> _buildRoute(String routeName) {
    final page = _pageForRoute(routeName);
    return PageRouteBuilder<void>(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide =
            Tween<Offset>(
              begin: const Offset(0.04, 0.02),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  Widget _pageForRoute(String routeName) {
    switch (routeName) {
      case '/meal':
        return const MealsScreen();
      case '/logs':
        return const NutritionHistoryScreen();
      case '/home':
        return const HomeScreen();
      case '/stats':
        return const DailyNutritionSummaryScreen();
      case '/settings':
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: SizedBox(
        height: 112,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = width / _items.length;
            final selectedCenterX = itemWidth * (_selectedIndex + 0.5);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 82,
                  child: CustomPaint(
                    painter: _BottomNavShapePainter(
                      selectedCenterX: selectedCenterX,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned.fill(
                  bottom: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final isSelected = index == _selectedIndex;

                      return _NavItem(
                        icon: item.icon,
                        label: item.label,
                        isSelected: isSelected,
                        color: isSelected ? _activeColor : _inactiveColor,
                        onTap: () => _selectItem(index),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;
  final String? routeName;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.routeName,
  });
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 46, bottom: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(icon, color: color, size: isSelected ? 29 : 27),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavShapePainter extends CustomPainter {
  final double selectedCenterX;
  final Color color;

  const _BottomNavShapePainter({
    required this.selectedCenterX,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    canvas.drawShadow(path, const Color(0x26000000), 10, false);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawPath(path, paint);
  }

  Path _buildPath(Size size) {
    const cornerRadius = 20.0;
    const topY = 14.0;
    const notchRadius = 41.0;
    final notchCenter = Offset(selectedCenterX, 36);
    final isNearLeftEdge = selectedCenterX < 108;
    final isNearRightEdge = selectedCenterX > size.width - 108;

    if (isNearLeftEdge || isNearRightEdge) {
      final body = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, topY, size.width, size.height - topY),
            const Radius.circular(cornerRadius),
          ),
        );
      final notch = Path()
        ..addOval(Rect.fromCircle(center: notchCenter, radius: notchRadius));

      return Path.combine(PathOperation.difference, body, notch);
    }

    final body = Path()
      ..moveTo(cornerRadius, topY)
      ..cubicTo(
        size.width * 0.20,
        topY - 12,
        selectedCenterX - 104,
        topY - 12,
        selectedCenterX - 58,
        topY,
      )
      ..cubicTo(
        selectedCenterX - 38,
        topY + 4,
        selectedCenterX - 38,
        topY + 38,
        selectedCenterX,
        topY + 38,
      )
      ..cubicTo(
        selectedCenterX + 38,
        topY + 38,
        selectedCenterX + 38,
        topY + 4,
        selectedCenterX + 58,
        topY,
      )
      ..cubicTo(
        selectedCenterX + 104,
        topY - 12,
        size.width * 0.80,
        topY - 12,
        size.width - cornerRadius,
        topY,
      )
      ..quadraticBezierTo(size.width, topY + 2, size.width, topY + cornerRadius)
      ..lineTo(size.width, size.height - cornerRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - cornerRadius,
        size.height,
      )
      ..lineTo(cornerRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cornerRadius)
      ..lineTo(0, topY + cornerRadius)
      ..quadraticBezierTo(0, topY + 2, cornerRadius, topY)
      ..close();

    final notch = Path()
      ..addOval(Rect.fromCircle(center: notchCenter, radius: notchRadius));

    return Path.combine(PathOperation.difference, body, notch);
  }

  @override
  bool shouldRepaint(covariant _BottomNavShapePainter oldDelegate) {
    return oldDelegate.selectedCenterX != selectedCenterX ||
        oldDelegate.color != color;
  }
}
