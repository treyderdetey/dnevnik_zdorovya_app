import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/providers/blood_pressure_provider.dart';
import '../../data/providers/medicine_provider.dart';
import '../../data/providers/mood_provider.dart';
import '../../data/providers/period_provider.dart';
import '../../data/providers/profile_provider.dart';
import '../../data/providers/streak_provider.dart';
import '../../data/providers/water_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();
    final medicine = context.watch<MedicineProvider>();
    final mood = context.watch<MoodProvider>();
    final streak = context.watch<StreakProvider>();
    final period = context.watch<PeriodProvider>();
    final profile = context.watch<ProfileProvider>();
    final bp = context.watch<BloodPressureProvider>();

    // Calculate health score
    final waterScore = water.todayProgress * 100;
    final medicineScore = medicine.todayCompletionRate * 100;
    final moodScore = mood.averageMoodScore * 20;
    final healthScore = (waterScore + medicineScore + moodScore) / 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Аналитика')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health score
            _buildHealthScore(healthScore)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 24),

            // Streaks
            _buildStreakSection(streak)
                .animate()
                .fadeIn(delay: 100.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: 24),

            // Water chart
            _buildWaterChart(water)
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Mood trend
            if (mood.entries.length >= 3)
              _buildMoodTrend(mood)
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.1),
            if (mood.entries.length >= 3) const SizedBox(height: 20),

            // Period summary (only for females)
            if (profile.isFemale)
              _buildPeriodSummary(period)
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideY(begin: 0.1),
            if (profile.isFemale) const SizedBox(height: 20),

            // Blood pressure summary
            if (bp.records.isNotEmpty)
              _buildBpSummary(bp)
                  .animate()
                  .fadeIn(delay: 450.ms)
                  .slideY(begin: 0.1),
            if (bp.records.isNotEmpty) const SizedBox(height: 20),

            // Medicine adherence
            _buildMedicineStats(medicine)
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScore(double score) {
    Color scoreColor;
    String label;
    if (score >= 80) {
      scoreColor = AppColors.success;
      label = 'Отлично!';
    } else if (score >= 60) {
      scoreColor = AppColors.waterColor;
      label = 'Хорошо';
    } else if (score >= 40) {
      scoreColor = AppColors.warning;
      label = 'Удовлетворительно';
    } else {
      scoreColor = AppColors.error;
      label = 'Требует внимания';
    }

    return GradientCard(
      gradient: LinearGradient(
        colors: [scoreColor, scoreColor.withValues(alpha: 0.7)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Общий показатель здоровья',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${score.round()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(StreakProvider streak) {
    final waterStreak = streak.getStreak('water');
    final medicineStreak = streak.getStreak('medicine');

    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('💧', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  '$waterStreak',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.waterColor,
                  ),
                ),
                Text(
                  'Серия (вода)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                Text(
                  'Рекорд: ${streak.getLongestStreak('water')}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('💊', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  '$medicineStreak',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.medicineColor,
                  ),
                ),
                Text(
                  'Серия (лекарства)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                Text(
                  'Рекорд: ${streak.getLongestStreak('medicine')}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaterChart(WaterProvider water) {
    final weeklyData = water.weeklyData;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: AppColors.waterColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Потребление воды (7 дней)',
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
                maxY: (water.dailyGoal + 2).toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final keys = weeklyData.keys.toList();
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
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups:
                    weeklyData.entries.toList().asMap().entries.map((e) {
                  final glasses = e.value.value.toDouble();
                  final isGoalMet = glasses >= water.dailyGoal;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: glasses,
                        gradient: isGoalMet
                            ? const LinearGradient(
                                colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
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

  Widget _buildMoodTrend(MoodProvider mood) {
    final entries = mood.weeklyMoods.reversed.toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mood, color: AppColors.moodColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Тренд настроения (7 дней)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < entries.length) {
                          return Text(
                            AppDateUtils.formatDateShort(entries[i].date)
                                .split(' ')
                                .first,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        const emojis = ['', '😢', '😔', '😐', '😊', '🤩'];
                        final i = value.toInt();
                        if (i >= 1 && i <= 5) {
                          return Text(emojis[i], style: const TextStyle(fontSize: 12));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: entries.asMap().entries.map((e) {
                      return FlSpot(
                        e.key.toDouble(),
                        e.value.moodScore.toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.moodColor, Color(0xFFFF9800)],
                    ),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: AppColors.moodColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.moodColor.withValues(alpha: 0.3),
                          AppColors.moodColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSummary(PeriodProvider period) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.periodColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Сводка за период',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Средний цикл', value: '${period.averageCycleLength.toStringAsFixed(1)} дн.'),
          _InfoRow(label: 'Всего записей', value: '${period.records.length}'),
          if (period.nextPeriodDate != null)
            _InfoRow(
              label: 'Следующий период',
              value: AppDateUtils.formatDate(period.nextPeriodDate!),
            ),
          if (period.daysUntilNextPeriod != null)
            _InfoRow(
              label: 'Дней до начала',
              value: '${period.daysUntilNextPeriod} дн.',
            ),
        ],
      ),
    );
  }

  Widget _buildBpSummary(BloodPressureProvider bp) {
    final latest = bp.latest;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.monitor_heart, color: Colors.redAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Сводка по давлению',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (latest != null) ...[
            _InfoRow(label: 'Последнее замер', value: '${latest.systolic}/${latest.diastolic}'),
            _InfoRow(label: 'Последний пульс', value: '${latest.pulse} уд/мин'),
          ],
          _InfoRow(label: 'Всего замеров', value: '${bp.records.length}'),
        ],
      ),
    );
  }

  Widget _buildMedicineStats(MedicineProvider medicine) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication, color: AppColors.medicineColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Обзор лекарств',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Активные лекарства',
            value: '${medicine.activeMedicines.length}',
          ),
          _InfoRow(
            label: "Прогресс сегодня",
            value: '${medicine.todayTakenCount}/${medicine.todayTotalCount} доз',
          ),
          _InfoRow(
            label: 'Соблюдение режима',
            value: '${(medicine.todayCompletionRate * 100).round()}%',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
