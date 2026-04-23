import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/haptic_utils.dart';
import '../../data/providers/gamification_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GamificationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Задания и награды')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level card
            _buildLevelCard(game)
                .animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 24),

            // Daily challenges
            const Text(
              'Задания на сегодня',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildChallenges(context, game),
            const SizedBox(height: 24),

            // Achievements
            const Text(
              'Достижения',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildAchievements(game),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(GamificationProvider game) {
    return GradientCard(
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B9D), Color(0xFFC850C0), Color(0xFF4158D0)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    '${game.currentLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.levelTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${game.totalPoints} всего очков',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: game.levelProgress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Уровень ${game.currentLevel}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${game.totalPoints % 100}/100 до следующего уровня',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallenges(BuildContext context, GamificationProvider game) {
    final challenges = game.todayChallenges;
    if (challenges.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text('Нет заданий на сегодня. Возвращайтесь завтра!'),
        ),
      );
    }

    return AnimationLimiter(
      child: Column(
        children: List.generate(challenges.length, (i) {
          final challenge = challenges[i];
    final categoryColors = {
      'water': AppColors.waterColor,
      'medicine': AppColors.medicineColor,
      'sleep': const Color(0xFF5C6BC0),
      'mood': AppColors.moodColor,
      'general': AppColors.primary,
    };
    final categoryIcons = {
      'water': Icons.water_drop_rounded,
      'medicine': Icons.medication_rounded,
      'sleep': Icons.bedtime_rounded,
      'mood': Icons.emoji_emotions_rounded,
      'general': Icons.star_rounded,
    };
          final color = categoryColors[challenge.category] ?? AppColors.primary;
          final icon = categoryIcons[challenge.category] ?? Icons.star;

          return AnimationConfiguration.staggeredList(
            position: i,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 30,
              child: FadeInAnimation(
                child: GlassCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  onTap: !challenge.completed
                      ? () {
                          HapticUtils.success();
                          game.completeChallenge(challenge.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('+${challenge.points} очков! 🎉'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: color,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      : null,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: challenge.completed
                              ? AppColors.success.withValues(alpha: 0.1)
                              : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          challenge.completed ? Icons.check_circle : icon,
                          color: challenge.completed ? AppColors.success : color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                decoration: challenge.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            Text(
                              challenge.description,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: challenge.completed
                              ? AppColors.success.withValues(alpha: 0.1)
                              : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+${challenge.points}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: challenge.completed
                                ? AppColors.success
                                : color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAchievements(GamificationProvider game) {
    final allDefs = game.allAchievementDefs;
    final earnedIds = game.achievements.map((a) => a.id).toSet();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: allDefs.map((def) {
            final isEarned = earnedIds.contains(def['id']);
            return Container(
              width: cardWidth,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isEarned
                ? AppColors.moodColor.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEarned
                  ? AppColors.moodColor.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              Text(
                def['icon']!,
                style: TextStyle(
                  fontSize: 32,
                  color: isEarned ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                def['title']!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isEarned ? null : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                def['desc']!,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              if (isEarned)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle, color: AppColors.success, size: 16),
                ),
            ],
          ),
        );
          }).toList(),
        );
      },
    );
  }
}
