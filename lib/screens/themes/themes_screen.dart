import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptic_utils.dart';
import '../../data/providers/gamification_provider.dart';
import '../../widgets/glass_card.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  final _settingsBox = Hive.box(AppConstants.settingsBox);
  late String _selectedTheme;

  static const List<Map<String, dynamic>> _themes = [
    {'id': 'default', 'name': 'Розовый', 'colors': [0xFFE91E8C, 0xFF9C27B0], 'icon': '🌹', 'cost': 0},
    {'id': 'lavender', 'name': 'Ловандовая мечта', 'colors': [0xFF7C4DFF, 0xFFB388FF], 'icon': '💜', 'cost': 0},
    {'id': 'mint', 'name': 'Свежая мята', 'colors': [0xFF26A69A, 0xFF80CBC4], 'icon': '🌿', 'cost': 50},
    {'id': 'coral', 'name': 'Кораловый закат', 'colors': [0xFFFF6B6B, 0xFFFF8A65], 'icon': '🌅', 'cost': 50},
    {'id': 'ocean', 'name': 'Океан', 'colors': [0xFF1565C0, 0xFF42A5F5], 'icon': '🌊', 'cost': 100},
    {'id': 'golden', 'name': 'Золотой', 'colors': [0xFFFF8F00, 0xFFFFCA28], 'icon': '✨', 'cost': 100},
    {'id': 'cherry', 'name': 'Цветущая вишня', 'colors': [0xFFEC407A, 0xFFF8BBD0], 'icon': '🌸', 'cost': 150},
    {'id': 'midnight', 'name': 'Полуночная галактика', 'colors': [0xFF1A237E, 0xFF7C4DFF], 'icon': '🌌', 'cost': 200},
    {'id': 'forest', 'name': 'Зачарованный лес', 'colors': [0xFF2E7D32, 0xFF66BB6A], 'icon': '🌲', 'cost': 200},
    {'id': 'royal', 'name': 'Королевский фиолетовый', 'colors': [0xFF6A1B9A, 0xFFCE93D8], 'icon': '👑', 'cost': 300},
    {'id': 'rainbow', 'name': 'Радужный взрыв', 'colors': [0xFFE91E63, 0xFFFF9800, 0xFF4CAF50, 0xFF2196F3], 'icon': '🌈', 'cost': 500},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTheme = _settingsBox.get(AppConstants.keyCustomTheme, defaultValue: 'по умолчанию');
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GamificationProvider>();
    final points = game.totalPoints;

    return Scaffold(
      appBar: AppBar(title: const Text('Темы')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points balance
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ваши очки', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text('$points очков',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.moodColor)),
                    ],
                  ),
                  const Spacer(),
                  const Text('Зарабатывай очки \nвыполняя задания',
                      style: TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.right),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 24),

            const Text('Выберите тему', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Theme grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _themes.length,
              itemBuilder: (context, i) {
                final theme = _themes[i];
                final isSelected = _selectedTheme == theme['id'];
                final cost = theme['cost'] as int;
                final isUnlocked = cost <= points || theme['id'] == 'default' || _selectedTheme == theme['id'];
                final colors = (theme['colors'] as List<int>).map((c) => Color(c)).toList();

                return GestureDetector(
                  onTap: () {
                    if (!isUnlocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Нужно $cost очков для разблокировки темы (у вас $points)')),
                      );
                      return;
                    }
                    HapticUtils.lightTap();
                    setState(() => _selectedTheme = theme['id'] as String);
                    _settingsBox.put(AppConstants.keyCustomTheme, theme['id']);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(18),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: colors.first.withValues(alpha: 0.5), blurRadius: 12, offset: const Offset(0, 4))]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(theme['icon'] as String, style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 8),
                              Text(
                                theme['name'] as String,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              if (cost > 0 && !isUnlocked)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('⭐ $cost', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(Icons.check_circle, color: Colors.white, size: 24),
                          ),
                        if (!isUnlocked)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Center(
                                child: Icon(Icons.lock, color: Colors.white54, size: 32),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).scale(begin: const Offset(0.9, 0.9));
              },
            ),
          ],
        ),
      ),
    );
  }
}
