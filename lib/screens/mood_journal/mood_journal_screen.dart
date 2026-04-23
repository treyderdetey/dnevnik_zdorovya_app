import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/haptic_utils.dart';
import '../../data/providers/mood_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';

class MoodJournalScreen extends StatefulWidget {
  const MoodJournalScreen({super.key});

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen> {
  int? _selectedMoodIndex;
  final _journalController = TextEditingController();
  final Set<String> _selectedTags = {};

  static const _moods = [
    {'emoji': '😢', 'label': 'Ужасно', 'score': 1, 'color': Color(0xFFEF5350)},
    {'emoji': '😔', 'label': 'Плохо', 'score': 2, 'color': Color(0xFFFF7043)},
    {'emoji': '😐', 'label': 'Нормально', 'score': 3, 'color': Color(0xFFFFCA28)},
    {'emoji': '😊', 'label': 'Хорошо', 'score': 4, 'color': Color(0xFF66BB6A)},
    {'emoji': '🤩', 'label': 'Отлично', 'score': 5, 'color': Color(0xFF42A5F5)},
  ];

  static const _tags = [
    'Работа', 'Спорт', 'Сон', 'Общение', 'Здоровье',
    'Еда', 'Семья', 'Путешествие', 'Учеба', 'Отдых',
  ];

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.watch<MoodProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Как вы себя чувствуете?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
            const SizedBox(height: 8),
            Text(
              AppDateUtils.formatDate(DateTime.now()),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),

            // Today's mood display (if already logged)
            if (mood.todayMood != null) _buildTodayMoodCard(mood),

            // Mood selector
            _buildMoodSelector(),
            const SizedBox(height: 24),

            // Tags
            _buildTagSelector(),
            const SizedBox(height: 20),

            // Journal text
            _buildJournalInput(),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMoodIndex != null
                    ? () => _saveMood(context, mood)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _selectedMoodIndex != null
                      ? (_moods[_selectedMoodIndex!]['color'] as Color)
                      : null,
                ),
                child: const Text('Сохранить настроение', style: TextStyle(fontSize: 16)),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 30),

            // Mood history
            _buildMoodHistory(mood),
            const SizedBox(height: 20),

            // Mood stats
            if (mood.entries.length >= 3) _buildMoodStats(mood),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMoodCard(MoodProvider mood) {
    final today = mood.todayMood!;
    return GradientCard(
      gradient: LinearGradient(
        colors: [
          (_moods[today.moodScore - 1]['color'] as Color),
          (_moods[today.moodScore - 1]['color'] as Color).withValues(alpha: 0.7),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Text(
            today.emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Сегодня вы чувствуете себя: ${today.moodLabel}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (today.journalText != null && today.journalText!.isNotEmpty)
                  Text(
                    today.journalText!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildMoodSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Выберите настроение',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_moods.length, (index) {
              final isSelected = _selectedMoodIndex == index;
              return GestureDetector(
                onTap: () {
                  HapticUtils.selection();
                  setState(() => _selectedMoodIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  width: isSelected ? 70 : 52,
                  height: isSelected ? 70 : 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (_moods[index]['color'] as Color).withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(isSelected ? 20 : 16),
                    border: isSelected
                        ? Border.all(
                            color: _moods[index]['color'] as Color,
                            width: 2.5,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _moods[index]['emoji'] as String,
                        style: TextStyle(fontSize: isSelected ? 30 : 24),
                      ),
                      if (isSelected)
                        Text(
                          _moods[index]['label'] as String,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _moods[index]['color'] as Color,
                          ),
                        ),
                    ],
                  ),
                ),
              ).animate(
                target: isSelected ? 1 : 0,
              ).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 200.ms,
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildTagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Что повлияло на ваше настроение?',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                HapticUtils.selection();
                setState(() {
                  isSelected
                      ? _selectedTags.remove(tag)
                      : _selectedTags.add(tag);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.moodColor.withValues(alpha: 0.2)
                      : Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.moodColor
                        : Colors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.moodColor : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildJournalInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Напишите о своем дне (необязательно)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _journalController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Как прошел ваш день? Что заставило вас так себя чувствовать?',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildMoodHistory(MoodProvider mood) {
    final entries = mood.entries.take(7).toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'История настроения',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AnimationLimiter(
          child: Column(
            children: List.generate(entries.length, (i) {
              final entry = entries[i];
              return AnimationConfiguration.staggeredList(
                position: i,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 30,
                  child: FadeInAnimation(
                    child: GlassCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Text(entry.emoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.moodLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  AppDateUtils.formatDate(entry.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (entry.tags.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.moodColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                entry.tags.first,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.moodColor,
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
        ),
      ],
    );
  }

  Widget _buildMoodStats(MoodProvider mood) {
    final dist = mood.moodDistribution;
    final avgScore = mood.averageMoodScore;
    final streak = mood.moodStreak;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Аналитика настроения',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Среднее',
                value: avgScore.toStringAsFixed(1),
                icon: Icons.analytics_rounded,
              ),
              _StatItem(
                label: 'Серия',
                value: '$streak дн.',
                icon: Icons.local_fire_department,
              ),
              _StatItem(
                label: 'Записи',
                value: '${mood.entries.length}',
                icon: Icons.edit_note,
              ),
            ],
          ),
          if (dist.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Распределение настроения',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: dist.entries.map((e) {
                return Column(
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 24)),
                    Text(
                      '${e.value}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Future<void> _saveMood(BuildContext context, MoodProvider mood) async {
    if (_selectedMoodIndex == null) return;

    HapticUtils.success();
    final selected = _moods[_selectedMoodIndex!];

    await mood.addMoodEntry(
      emoji: selected['emoji'] as String,
      moodLabel: selected['label'] as String,
      moodScore: selected['score'] as int,
      journalText: _journalController.text.trim().isNotEmpty
          ? _journalController.text.trim()
          : null,
      tags: _selectedTags.toList(),
    );

    setState(() {
      _selectedMoodIndex = null;
      _selectedTags.clear();
      _journalController.clear();
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Настроение сохранено! Продолжайте следить за своими чувствами.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: selected['color'] as Color,
        ),
      );
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.moodColor, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }
}
