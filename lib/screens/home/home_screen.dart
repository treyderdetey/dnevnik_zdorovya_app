import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/health_tips.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/utils/loader_transitions.dart';
import '../../data/providers/medicine_provider.dart';
import '../../data/providers/period_provider.dart';
import '../../data/providers/profile_provider.dart';
import '../../data/providers/streak_provider.dart';
import '../../data/providers/water_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';
import '../analytics/analytics_screen.dart';
import '../weight_tracker/weight_tracker_screen.dart';
import '../water_tracker/water_tracker_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final period = context.watch<PeriodProvider>();
    final medicine = context.watch<MedicineProvider>();
    final water = context.watch<WaterProvider>();
    final streak = context.watch<StreakProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие
            _buildGreeting(context, profile.name)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.1),
            const SizedBox(height: 20),

            // Быстрая статистика
            _buildQuickStats(context, profile, period, medicine, water, streak)
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Карточка воды
            _buildWaterCard(context, water)
                .animate()
                .fadeIn(delay: 300.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Совет дня
            _buildHealthTipCard(context, profile)
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Быстрый доступ (ИМТ + Аналитика)
            _buildQuickAccessRow(context)
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Лекарства на сегодня
            _buildTodayMedicines(context, medicine)
                .animate()
                .fadeIn(delay: 600.ms),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String name) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;
    if (hour >= 5 && hour < 12) {
      greeting = 'Доброе утро';
      icon = Icons.wb_sunny_rounded;
    } else if (hour >= 12 && hour < 18) {
      greeting = 'Добрый день';
      icon = Icons.wb_cloudy_rounded;
    } else if (hour >= 18 && hour < 23) {
      greeting = 'Добрый вечер';
      icon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Доброй ночи';
      icon = Icons.nights_stay_rounded;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.moodColor),
                  const SizedBox(width: 6),
                  Text(
                    greeting,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                name.isNotEmpty ? name : 'Добро пожаловать!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                AppDateUtils.formatDate(DateTime.now()),
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    ProfileProvider profile,
    PeriodProvider period,
    MedicineProvider medicine,
    WaterProvider water,
    StreakProvider streak,
  ) {
    final waterStreak = streak.getStreak('water');
    final medStreak = streak.getStreak('medicine');
    final isFemale = profile.isFemale;

    return Row(
      children: [
        if (isFemale) ...[
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  const Icon(Icons.favorite_rounded,
                      color: AppColors.periodColor, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    period.isOnPeriod
                        ? 'День ${period.currentCycleDay}'
                        : period.daysUntilNextPeriod != null
                            ? '${period.daysUntilNextPeriod} дн.'
                            : '--',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.periodColor,
                    ),
                  ),
                  Text('Цикл',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Icon(Icons.medication_rounded,
                    color: AppColors.medicineColor, size: 28),
                const SizedBox(height: 8),
                Text(
                  '${medicine.todayTakenCount}/${medicine.todayTotalCount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.medicineColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Лекарства',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                    if (medStreak > 0) ...[
                      const SizedBox(width: 4),
                      Text('🔥$medStreak',
                          style: const TextStyle(fontSize: 10)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Icon(Icons.water_drop_rounded,
                    color: AppColors.waterColor, size: 28),
                const SizedBox(height: 8),
                Text(
                  '${water.todayGlasses}/${water.dailyGoal}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.waterColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Вода',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                    if (waterStreak > 0) ...[
                      const SizedBox(width: 4),
                      Text('🔥$waterStreak',
                          style: const TextStyle(fontSize: 10)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaterCard(BuildContext context, WaterProvider water) {
    return GradientCard(
      gradient: AppGradients.water,
      onTap: () {
        Navigator.of(context).push(
          LoaderPageRoute(page: const WaterTrackerScreen()),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Потребление воды',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${water.todayMl} мл / ${water.goalMl} мл',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: water.todayProgress,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTipCard(BuildContext context, ProfileProvider profile) {
    final categories = HealthTips.categories
        .where((c) => profile.isFemale || c != 'Здоровье женщины')
        .toList();
    final dayIndex = DateTime.now().day % categories.length;
    final category = categories[dayIndex];
    final tip = HealthTips.getDailyTip(category);

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.healthColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lightbulb_rounded,
                    color: AppColors.healthColor, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Совет дня',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.healthColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.healthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tip,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GradientCard(
            gradient: AppGradients.bmi,
            padding: const EdgeInsets.all(16),
            onTap: () {
              Navigator.of(context).push(
                LoaderPageRoute(page: const WeightTrackerScreen()),
              );
            },
            child: const Column(
              children: [
                Icon(Icons.monitor_weight_rounded,
                    color: Colors.white, size: 32),
                SizedBox(height: 8),
                Text(
                  'Вес и\nтело',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GradientCard(
            gradient: AppGradients.analytics,
            padding: const EdgeInsets.all(16),
            onTap: () {
              Navigator.of(context).push(
                LoaderPageRoute(page: const AnalyticsScreen()),
              );
            },
            child: const Column(
              children: [
                Icon(Icons.analytics_rounded, color: Colors.white, size: 32),
                SizedBox(height: 8),
                Text(
                  'Аналитика\nздоровья',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayMedicines(BuildContext context, MedicineProvider medicine) {
    final doses = medicine.todayDoses;
    if (doses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Лекарства на сегодня",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...doses.take(5).map((dose) {
          final medicineName = medicine.getMedicineName(dose.medicineId);
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dose.taken
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.medicineColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    dose.taken
                        ? Icons.check_circle_rounded
                        : Icons.medication_rounded,
                    color:
                        dose.taken ? AppColors.success : AppColors.medicineColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicineName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration:
                              dose.taken ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(
                        AppDateUtils.formatTime(dose.scheduledTime),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                if (!dose.taken)
                  TextButton(
                    onPressed: () {
                      HapticUtils.lightTap();
                      medicine.markDoseTaken(dose.id);
                    },
                    child: const Text('Принять'),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
