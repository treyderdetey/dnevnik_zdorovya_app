import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/health_tips.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/utils/loader_transitions.dart';
import '../../data/providers/profile_provider.dart';

import '../../data/providers/theme_provider.dart';
import '../analytics/analytics_screen.dart';
import '../emergency_sos/emergency_sos_screen.dart';
import '../export_report/export_report_screen.dart';
import '../gamification/gamification_screen.dart';
import '../habit_tracker/habit_tracker_screen.dart';
import '../sleep_tracker/sleep_tracker_screen.dart';
import '../water_tracker/water_tracker_screen.dart';
import '../weight_tracker/weight_tracker_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final theme = context.watch<ThemeProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Profile header
            _buildProfileHeader(context, profile),
            const SizedBox(height: 24),

            // Quick links
            _buildMenuCard(
              context,
              icon: Icons.water_drop_rounded,
              title: 'Трекер воды',
              subtitle: 'Ежедневное потребление',
              color: AppColors.waterColor,
              onTap: () => Navigator.push(
                context,
                LoaderPageRoute(page: const WaterTrackerScreen()),
              ),
            ),
            _buildMenuCard(
              context,
              icon: Icons.monitor_weight_rounded,
              title: 'Вес и тело',
              subtitle: 'Трекер параметров и ИМТ',
              color: AppColors.bmiColor,
              onTap: () {
                HapticUtils.lightTap();
                Navigator.push(
                  context,
                  LoaderPageRoute(page: const WeightTrackerScreen()),
                );
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.analytics_rounded,
              title: 'Аналитика',
              subtitle: 'Ваши показатели здоровья',
              color: AppColors.analyticsColor,
              onTap: () {
                HapticUtils.lightTap();
                Navigator.push(
                  context,
                  LoaderPageRoute(page: const AnalyticsScreen()),
                );
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.bedtime_rounded,
              title: 'Трекер сна',
              subtitle: 'Контроль режима сна',
              color: const Color(0xFF5C6BC0),
              onTap: () {
                HapticUtils.lightTap();
                Navigator.push(context, LoaderPageRoute(page: const SleepTrackerScreen()));
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.emoji_events_rounded,
              title: 'Достижения и награды',
              subtitle: 'Ваш прогресс и задания',
              color: AppColors.moodColor,
              onTap: () {
                HapticUtils.lightTap();
                Navigator.push(context, LoaderPageRoute(page: const GamificationScreen()));
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.checklist_rounded,
              title: 'Полезные привычки',
              subtitle: 'Формируйте здоровый образ жизни',
              color: AppColors.periodColor,
              onTap: () {
                HapticUtils.lightTap();
                Navigator.push(context, LoaderPageRoute(page: const HabitTrackerScreen()));
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.sos_rounded,
              title: 'Экстренный SOS',
              subtitle: 'Быстрая помощь',
              color: AppColors.error,
              onTap: () {
                HapticUtils.lightTap();
                Navigator.push(context, LoaderPageRoute(page: const EmergencySosScreen()));
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.picture_as_pdf_rounded,
              title: 'Экспорт отчета',
              subtitle: 'PDF для врача',
              color: AppColors.analyticsColor,
              onTap: () {
                HapticUtils.lightTap();
                Navigator.push(context, LoaderPageRoute(page: const ExportReportScreen()));
              },
            ),
            _buildMenuCard(
              context,
              icon: theme.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              title: theme.isDarkMode ? 'Светлая тема' : 'Темная тема',
              subtitle: 'Сменить вид приложения',
              color: AppColors.secondary,
              onTap: theme.toggleTheme,
            ),

            _buildMenuCard(
              context,
              icon: Icons.settings_rounded,
              title: 'Настройки',
              subtitle: 'Предпочтения приложения',
              color: Colors.grey,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            _buildMenuCard(
              context,
              icon: Icons.info_outline_rounded,
              title: 'О приложении',
              subtitle: 'Версия 1.0.0',
              color: AppColors.info,
              onTap: () => _showAbout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileProvider profile) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              profile.name.isNotEmpty
                  ? profile.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.name.isNotEmpty ? profile.name : 'Укажите имя',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (profile.age > 0)
          Text(
            'Возраст: ${profile.age}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showEditProfile(context, profile),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Изменить профиль'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context, ProfileProvider profile) {
    final nameController = TextEditingController(text: profile.name);
    final ageController = TextEditingController(
        text: profile.age > 0 ? profile.age.toString() : '');
    final heightController = TextEditingController(
        text: profile.height > 0 ? profile.height.toStringAsFixed(0) : '');
    String selectedGender = profile.gender;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24, 24, 24,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Редактировать профиль',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Имя',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Обязательно' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Возраст',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Обязательно';
                        final age = int.tryParse(v);
                        if (age == null || age < 10 || age > 100) {
                          return 'Введите корректный возраст (10-100)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Рост (см)',
                        prefixIcon: Icon(Icons.height_rounded),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Обязательно';
                        final h = double.tryParse(v);
                        if (h == null || h < 100 || h > 250) {
                          return 'Введите корректный рост (100-250)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ваш пол',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderToggle(
                            label: 'Женский',
                            icon: Icons.female,
                            isSelected: selectedGender == 'female',
                            onTap: () => setSheetState(() => selectedGender = 'female'),
                            color: AppColors.periodColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGenderToggle(
                            label: 'Мужской',
                            icon: Icons.male,
                            isSelected: selectedGender == 'male',
                            onTap: () => setSheetState(() => selectedGender = 'male'),
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          profile.updateProfile(
                            name: nameController.text.trim(),
                            age: int.parse(ageController.text.trim()),
                            height: double.parse(heightController.text.trim()),
                            gender: selectedGender,
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Сохранить'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGenderToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHealthTips(BuildContext context) {
    final profile = context.read<ProfileProvider>();
    final categories = HealthTips.categories
        .where((c) => profile.isFemale || c != 'Здоровье женщины')
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (ctx, scrollController) {
            return DefaultTabController(
              length: categories.length,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Советы по здоровью',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    tabs: categories
                        .map((c) => Tab(text: c))
                        .toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: categories.map((category) {
                        final tips = HealthTips.getTips(category);
                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: tips.length,
                          itemBuilder: (_, i) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.healthColor
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.healthColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          color: AppColors.healthColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      tips[i],
                                      style: const TextStyle(
                                        height: 1.4,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Моё здоровье',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 24),
      ),
      children: [
        const Text(
          'Ваш надежный спутник в вопросах здоровья.\n\n'
          'Следите за циклом, приемом лекарств, водой и получайте '
          'полезные советы каждый день.',
        ),
      ],
    );
  }
}
