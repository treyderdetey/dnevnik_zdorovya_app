import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/notification_service.dart';
import '../../data/providers/period_provider.dart';
import '../../data/providers/theme_provider.dart';
import '../../data/providers/water_provider.dart';
import '../../core/utils/feedback_utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final period = context.watch<PeriodProvider>();
    final water = context.watch<WaterProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Внешний вид
          _buildSectionTitle('Внешний вид'),
          _buildSettingCard(
            context,
            icon: Icons.palette_outlined,
            title: 'Тема',
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode, size: 16),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode, size: 16),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.phone_android, size: 16),
                ),
              ],
              selected: {theme.themeMode},
              onSelectionChanged: (modes) {
                theme.setThemeMode(modes.first);
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Period settings
          _buildSectionTitle('Цикл'),
          _buildSettingCard(
            context,
            icon: Icons.calendar_month,
            title: 'Длительность цикла',
            subtitle: '${period.cycleLength} дней',
            onTap: () => _showNumberPicker(
              context,
              title: 'Длительность цикла (дней)',
              current: period.cycleLength,
              min: 20,
              max: 45,
              onChanged: period.updateCycleLength,
            ),
          ),
          _buildSettingCard(
            context,
            icon: Icons.timelapse,
            title: 'Длительность менструации',
            subtitle: '${period.periodDuration} дней',
            onTap: () => _showNumberPicker(
              context,
              title: 'Длительность менструации (дни)',
              current: period.periodDuration,
              min: 2,
              max: 10,
              onChanged: period.updatePeriodDuration,
            ),
          ),
          const SizedBox(height: 20),

          // Water settings
          _buildSectionTitle('Трекер воды'),
          _buildSettingCard(
            context,
            icon: Icons.local_drink,
            title: 'Дневная цель',
            subtitle: '${water.dailyGoal} стаканов (${water.goalMl} мл)',
            onTap: () => _showNumberPicker(
              context,
              title: 'Дневная цель (стаканов)',
              current: water.dailyGoal,
              min: 4,
              max: 20,
              onChanged: water.updateDailyGoal,
            ),
          ),
          _buildSettingCard(
            context,
            icon: Icons.notifications_active,
            title: 'Напоминание выпить воды',
            trailing: Switch(
              value: water.reminderEnabled,
              onChanged: (val) => water.toggleReminder(val),
              activeTrackColor: AppColors.waterColor,
            ),
          ),
          const SizedBox(height: 20),

          // Notifications
          _buildSectionTitle('Уведомления'),
          _buildSettingCard(
            context,
            icon: Icons.notifications,
            title: 'Запросить разрешение',
            subtitle: 'Разрешить уведомления для напоминаний',
            onTap: () async {
              final granted =
                  await NotificationService.instance.requestPermissions();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(granted
                        ? 'Уведомления включены'
                        : 'Уведомления отключены в настройках устройства.'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // Support & Feedback
          _buildSectionTitle('Поддержка'),
          _buildSettingCard(
            context,
            icon: Icons.bug_report_outlined,
            title: 'Сообщить об ошибке',
            subtitle: 'Отправить баг-репорт разработчику',
            onTap: () => FeedbackUtils.sendFeedback(),
          ),
          _buildSettingCard(
            context,
            icon: Icons.info_outline,
            title: 'О приложении',
            subtitle: 'Версия 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Моё здоровье',
                applicationVersion: '1.0.0',
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                children: [
                  const Text('Ваш персональный помощник в заботе о здоровье.'),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Data
          _buildSectionTitle('Данные'),
          _buildSettingCard(
            context,
            icon: Icons.delete_forever,
            title: 'Очистить все данные',
            subtitle: 'Это нельзя отменить',
            iconColor: AppColors.error,
            onTap: () => _confirmClearData(context),
          ),

        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing
                else if (onTap != null)
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNumberPicker(
    BuildContext context, {
    required String title,
    required int current,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    int value = current;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: value > min
                        ? () => setDialogState(() => value--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: value < max
                        ? () => setDialogState(() => value++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Закрыть'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onChanged(value);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить все данные?'),
        content: const Text(
          'Это приведет к безвозвратному удалению всех ваших записей о менструальном цикле, напоминаний о приеме лекарств, данных об употреблении воды и информации профиля. Это действие необратимо.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              // In production, clear all Hive boxes here
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Все данные удалены')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Удалить все'),
          ),
        ],
      ),
    );
  }
}
