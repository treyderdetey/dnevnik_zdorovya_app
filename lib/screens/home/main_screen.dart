import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/haptic_utils.dart';
import '../../data/providers/medicine_provider.dart';
import '../../data/providers/profile_provider.dart';
import '../../widgets/app_loader.dart';
import '../period_tracker/period_tracker_screen.dart';
import '../blood_pressure/blood_pressure_screen.dart';
import '../medicine_reminder/medicine_reminder_screen.dart';
import '../mood_journal/mood_journal_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isTransitioning = false;
  bool? _lastIsFemale; // Храним предыдущее состояние пола

  List<Widget> _getScreens(bool isFemale) {
    return [
      const HomeScreen(),
      if (isFemale) const PeriodTrackerScreen(),
      const BloodPressureScreen(),
      const MoodJournalScreen(),
      const MedicineReminderScreen(),
      const ProfileScreen(),
    ];
  }

  List<IconData> _getNavIcons(bool isFemale) {
    return [
      Icons.home_rounded,
      if (isFemale) Icons.favorite_rounded,
      Icons.monitor_heart_rounded,
      Icons.emoji_emotions_rounded,
      Icons.medication_rounded,
      Icons.person_rounded,
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().ensureTodayDoses();
    });
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;

    HapticUtils.lightTap();
    setState(() => _isTransitioning = true);

    // Short loader before showing new tab
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _currentIndex = index;
          _isTransitioning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>();
    final isFemale = profile.isFemale;
    final screens = _getScreens(isFemale);

    // Логика сохранения текущей страницы при смене пола
    if (_lastIsFemale != null && _lastIsFemale != isFemale) {
      if (_lastIsFemale!) {
        // Смена Женщина -> Мужчина (убрали календарь под индексом 1)
        if (_currentIndex > 1) {
          _currentIndex -= 1;
        } else if (_currentIndex == 1) {
          _currentIndex = 0; // Был на календаре, кидаем на главную
        }
      } else {
        // Смена Мужчина -> Женщина (добавили календарь под индексом 1)
        if (_currentIndex >= 1) {
          _currentIndex += 1;
        }
      }
    }
    _lastIsFemale = isFemale;

    // Автоматическая корректировка индекса (защита)
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _isTransitioning
            ? const Center(
                key: ValueKey('loader'),
                child: AppLoader(
                  size: 60,
                  showMessage: false,
                ),
              )
            : KeyedSubtree(
                key: ValueKey(_currentIndex),
                child: screens[_currentIndex],
              ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: ValueKey('nav_$isFemale'), // Добавляем ключ, зависящий от пола
        index: _currentIndex,
        height: 65,
        backgroundColor: Colors.transparent,
        color: isDark ? AppColors.cardDark : Colors.white,
        buttonBackgroundColor: AppColors.primary,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOutCubic,
        items: _getNavIcons(isFemale).asMap().entries.map((entry) {
          final index = entry.key;
          final icon = entry.value;
          return Icon(
            icon,
            size: 26,
            color: _currentIndex == index ? Colors.white : Colors.grey,
          );
        }).toList(),
        onTap: _onTabTap,
      ),
    );
  }
}
