import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/constants/home_remedies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptic_utils.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';

class HomeRemediesScreen extends StatelessWidget {
  const HomeRemediesScreen({super.key});

  static const _categoryIcons = {
    'Period Pain Relief': '🩸',
    'PCOD / PCOS': '💜',
    'Skin Glow': '✨',
    'Hair Growth': '💇‍♀️',
    'Digestion & Bloating': '🫖',
    'Immunity Boosting': '🛡️',
  };

  static const _categoryColors = {
    'Period Pain Relief': AppColors.periodColor,
    'PCOD / PCOS': AppColors.medicineColor,
    'Skin Glow': AppColors.moodColor,
    'Hair Growth': AppColors.healthColor,
    'Digestion & Bloating': AppColors.bmiColor,
    'Immunity Boosting': AppColors.waterColor,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Домашние средства')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
              ),
              child: const Row(
                children: [
                  Text('🌿', style: TextStyle(fontSize: 36)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Домашние средства', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Природные рецепты из индийской традиции', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 24),

            // Category cards
            AnimationLimiter(
              child: Column(
                children: HomeRemedies.categories.asMap().entries.map((entry) {
                  final i = entry.key;
                  final category = entry.value;
                  final icon = _categoryIcons[category] ?? '🌿';
                  final color = _categoryColors[category] ?? AppColors.healthColor;
                  final count = HomeRemedies.getRemedies(category).length;

                  return AnimationConfiguration.staggeredList(
                    position: i,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 30,
                      child: FadeInAnimation(
                        child: GlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          onTap: () {
                            HapticUtils.lightTap();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _RemedyListScreen(
                                  category: category,
                                  icon: icon,
                                  color: color,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                    Text('$count средств', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemedyListScreen extends StatelessWidget {
  final String category;
  final String icon;
  final Color color;

  const _RemedyListScreen({
    required this.category,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final remedies = HomeRemedies.getRemedies(category);

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: remedies.length,
          itemBuilder: (context, i) {
            final remedy = remedies[i];
            return AnimationConfiguration.staggeredList(
              position: i,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 30,
                child: FadeInAnimation(
                  child: GlassCard(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                remedy['Название']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          remedy['Рецепт']!,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_grocery_store, size: 14, color: color),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  remedy['Ингридиетнты']!,
                                  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
