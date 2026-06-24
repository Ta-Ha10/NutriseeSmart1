import 'package:flutter/material.dart';

import '../Screens/Signup/meals_screen.dart';
import '../Screens/daily_nutrition_summary_screen.dart';
import '../Screens/nutrition_history_screen.dart';
import '../main/home_screen.dart';
import '../main/setting.dart';
import '../l10n/app_locale.dart';

class AppBottomNav extends StatefulWidget {
  final int selectedIndex;

  const AppBottomNav({super.key, this.selectedIndex = 2});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  static const Color _activeColor = Color(0xFF49B44E);
  static const Color _inactiveColor = Color(0xFF94A3B8);

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
    Navigator.of(context).push(_buildRoute(routeName));
  }

  PageRouteBuilder<void> _buildRoute(String routeName) {
    final page = _pageForRoute(routeName);
    return PageRouteBuilder<void>(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0.10, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final scale = Tween<double>(begin: 0.98, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: SlideTransition(position: slide, child: child),
          ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final barBorderColor = isDarkMode
        ? colorScheme.outlineVariant.withValues(alpha: 0.45)
        : const Color(0xFFE7E7E7);
    final barShadowColor = isDarkMode
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.06);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: SizedBox(
        height: 94,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: barBorderColor),
            boxShadow: [
              BoxShadow(
                color: barShadowColor,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = index == _selectedIndex;
              final isCenter = index == 2;
              final label = AppStrings.bottomNavLabel(context, item.routeName!) ??
                  item.label;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _selectItem(index),
                  child: isCenter
                      ? _CenterHomeItem(
                          icon: isSelected ? Icons.cottage : Icons.cottage_outlined,
                          label: label,
                          isSelected: isSelected,
                          activeColor: _activeColor,
                          inactiveColor: _inactiveColor,
                        )
                      : _TabItem(
                          icon: item.icon,
                          label: label,
                          isSelected: isSelected,
                          activeColor: _activeColor,
                          inactiveColor: _inactiveColor,
                        ),
                ),
              );
            }),
          ),
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

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? activeColor : inactiveColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterHomeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;

  const _CenterHomeItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isSelected ? activeColor : inactiveColor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(0, -12),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeColor,
              border: Border.all(color: activeColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 31,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: labelColor,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
