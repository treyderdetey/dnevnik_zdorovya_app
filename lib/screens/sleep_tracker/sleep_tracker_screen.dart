import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/haptic_utils.dart';
import '../../data/providers/sleep_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  int _quality = 3;

  static const _qualities = [
    {'emoji': '😫', 'label': 'Ужасно', 'score': 1, 'color': Color(0xFFEF5350)},
    {'emoji': '😴', 'label': 'Плохо', 'score': 2, 'color': Color(0xFFFF7043)},
    {'emoji': '😐', 'label': 'Нормально', 'score': 3, 'color': Color(0xFFFFCA28)},
    {'emoji': '😊', 'label': 'Хорошо', 'score': 4, 'color': Color(0xFF66BB6A)},
    {'emoji': '🌟', 'label': 'Отлично', 'score': 5, 'color': Color(0xFF42A5F5)},
  ];
  static const _sleepColor = Color(0xFF5C6BC0);

  @override
  Widget build(BuildContext context) {
    final sleep = context.watch<SleepProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Трекер сна')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Last night summary
            if (sleep.lastNight != null)
              _buildLastNightCard(sleep)
                  .animate().fadeIn().slideY(begin: 0.1),
            if (sleep.lastNight != null) const SizedBox(height: 20),

            // Log sleep
            _buildLogSleepCard(context, sleep)
                .animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Quality selector
            _buildQualitySelector()
                .animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _saveSleep(context, sleep),
                icon: const Icon(Icons.bedtime_rounded),
                label: const Text('Сохранить запись сна', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sleepColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 24),

            // Weekly chart
            _buildWeeklyChart(sleep)
                .animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Stats
            _buildStatsCard(sleep)
                .animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Bedtime reminder
            _buildReminderSettings(sleep)
                .animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // History
            _buildHistory(sleep),
          ],
        ),
      ),
    );
  }

  Widget _buildLastNightCard(SleepProvider sleep) {
    final record = sleep.lastNight!;
    return GradientCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
      ),
      child: Row(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Последняя ночь',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  record.durationFormatted,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${record.qualityLabel} качество',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _qualities[record.quality - 1]['emoji'] as String,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogSleepCard(BuildContext context, SleepProvider sleep) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Записывайте свой сон',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _TimePickerTile(
                  label: 'Время сна',
                  icon: Icons.bedtime_rounded,
                  time: _bedTime,
                  color: const Color(0xFF5C6BC0),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _bedTime,
                    );
                    if (picked != null) setState(() => _bedTime = picked);
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward, color: Colors.grey),
              ),
              Expanded(
                child: _TimePickerTile(
                  label: 'Пробуждение',
                  icon: Icons.wb_sunny_rounded,
                  time: _wakeTime,
                  color: AppColors.moodColor,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _wakeTime,
                    );
                    if (picked != null) setState(() => _wakeTime = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Длительность: ${_calculateDuration()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _sleepColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySelector() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Выберите качество сна',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_qualities.length, (index) {
              final isSelected = _quality == index + 1;
              final item = _qualities[index];
              return GestureDetector(
                onTap: () {
                  HapticUtils.selection();
                  setState(() => _quality = index + 1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  width: isSelected ? 70 : 52,
                  height: isSelected ? 70 : 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (item['color'] as Color).withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(isSelected ? 20 : 16),
                    border: isSelected
                        ? Border.all(
                            color: item['color'] as Color,
                            width: 2.5,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['emoji'] as String,
                        style: TextStyle(fontSize: isSelected ? 30 : 24),
                      ),
                      if (isSelected)
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: item['color'] as Color,
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
    );
  }

  Widget _buildWeeklyChart(SleepProvider sleep) {
    final data = sleep.weeklySleepData;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bedtime, color: _sleepColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Сон на этой неделе',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 12,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final keys = data.keys.toList();
                        if (value.toInt() < keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              keys[value.toInt()].split(' ').first,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) =>
                          Text('${value.toInt()}ч', style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: data.entries.toList().asMap().entries.map((e) {
                  final hours = e.value.value;
                  final isGood = hours >= 7;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: hours,
                        gradient: LinearGradient(
                          colors: isGood
                              ? [const Color(0xFF66BB6A), const Color(0xFF43A047)]
                              : [const Color(0xFF5C6BC0), const Color(0xFF3949AB)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(SleepProvider sleep) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Статистика сна', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Средняя длительность', value: '${sleep.averageDuration.toStringAsFixed(1)}ч'),
              _StatItem(label: 'Среднее качество', value: sleep.averageQuality.toStringAsFixed(1)),
              _StatItem(label: 'Серия', value: '${sleep.sleepStreak}дн.'),
              _StatItem(label: 'Записи', value: '${sleep.records.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSettings(SleepProvider sleep) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Напоминание о времени отхода ко сну', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Напоминать ${sleep.bedtimeReminder.format(context)}'),
              Switch(
                value: sleep.reminderEnabled,
                onChanged: sleep.toggleReminder,
                activeTrackColor: _sleepColor,
              ),
            ],
          ),
          if (sleep.reminderEnabled)
            TextButton.icon(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: sleep.bedtimeReminder,
                );
                if (picked != null) sleep.setBedtimeReminder(picked);
              },
              icon: const Icon(Icons.access_time, size: 16),
              label: const Text('Изменить время'),
            ),
        ],
      ),
    );
  }

  Widget _buildHistory(SleepProvider sleep) {
    final records = sleep.records.take(5).toList();
    if (records.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('История', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...records.map((r) => GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(_qualities[r.quality - 1]['emoji'] as String, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppDateUtils.formatDate(r.date),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${r.durationFormatted} • ${r.qualityLabel}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  String _calculateDuration() {
    final now = DateTime.now();
    var bed = DateTime(now.year, now.month, now.day, _bedTime.hour, _bedTime.minute);
    var wake = DateTime(now.year, now.month, now.day, _wakeTime.hour, _wakeTime.minute);
    if (wake.isBefore(bed)) wake = wake.add(const Duration(days: 1));
    final diff = wake.difference(bed);
    return '${diff.inHours}ч ${diff.inMinutes % 60}м';
  }

  void _saveSleep(BuildContext context, SleepProvider sleep) {
    HapticUtils.success();
    final now = DateTime.now();
    var bed = DateTime(now.year, now.month, now.day, _bedTime.hour, _bedTime.minute);
    var wake = DateTime(now.year, now.month, now.day, _wakeTime.hour, _wakeTime.minute);
    if (wake.isBefore(bed)) wake = wake.add(const Duration(days: 1));

    sleep.addSleepRecord(bedTime: bed, wakeTime: wake, quality: _quality);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Запись сна сохранена!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: _sleepColor,
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final TimeOfDay time;
  final Color color;
  final VoidCallback onTap;

  const _TimePickerTile({
    required this.label,
    required this.icon,
    required this.time,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            Text(
              time.format(context),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _SleepTrackerScreenState._sleepColor)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}
