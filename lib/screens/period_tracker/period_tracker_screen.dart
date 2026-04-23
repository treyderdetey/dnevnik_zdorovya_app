import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/providers/period_provider.dart';

class PeriodTrackerScreen extends StatefulWidget {
  const PeriodTrackerScreen({super.key});

  @override
  State<PeriodTrackerScreen> createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final period = context.watch<PeriodProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Женский календарь',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Status card
            _buildStatusCard(context, period),
            const SizedBox(height: 20),

            // Calendar
            _buildCalendar(context, period),
            const SizedBox(height: 20),

            // Quick actions
            _buildQuickActions(context, period),
            const SizedBox(height: 20),

            // Cycle settings
            _buildCycleSettings(context, period),
            const SizedBox(height: 20),

            // Symptoms section
            if (_selectedDay != null) ...[
              _buildSymptomSection(context, period),
              const SizedBox(height: 20),
            ],

            // Cycle summary
            _buildCycleSummary(context, period),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, PeriodProvider period) {
    final isOnPeriod = period.isOnPeriod;
    final daysUntil = period.daysUntilNextPeriod;
    final cycleDay = period.currentCycleDay;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isOnPeriod
            ? const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
              )
            : const LinearGradient(
                colors: [Color(0xFFF8BBD0), Color(0xFFE1BEE7)],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.periodColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isOnPeriod ? Icons.favorite : Icons.favorite_border,
            color: isOnPeriod ? Colors.white : AppColors.periodColor,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            isOnPeriod
                ? 'Идут месячные'
                : daysUntil != null
                    ? (daysUntil > 0
                        ? '$daysUntil дней до начала'
                        : 'Месячные ожидаются сегодня')
                    : 'Укажите дату последних месячных',
            style: TextStyle(
              color: isOnPeriod ? Colors.white : AppColors.textPrimaryLight,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (cycleDay != null) ...[
            const SizedBox(height: 8),
            Text(
              'День цикла $cycleDay из ${period.cycleLength}',
              style: TextStyle(
                color: isOnPeriod ? Colors.white70 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
          if (period.nextPeriodDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'След.: ${AppDateUtils.formatDate(period.nextPeriodDate!)}',
              style: TextStyle(
                color: isOnPeriod ? Colors.white60 : Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, PeriodProvider period) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        locale: 'ru_RU',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Месяц',
          CalendarFormat.twoWeeks: '2 недели',
          CalendarFormat.week: 'Неделя',
        },
        selectedDayPredicate: (day) =>
            _selectedDay != null && AppDateUtils.isSameDay(_selectedDay!, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            if (period.isPeriodDay(day)) {
              return _buildPeriodDayCell(day, AppColors.periodColor);
            }
            if (period.isPredictedPeriodDay(day)) {
              return _buildPeriodDayCell(
                  day, AppColors.periodColor.withValues(alpha: 0.4));
            }
            return null;
          },
          todayBuilder: (context, day, focusedDay) {
            final isPeriod = period.isPeriodDay(day);
            return Container(
              margin: const EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isPeriod ? AppColors.periodColor : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${day.day}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle: const TextStyle(color: AppColors.primary),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodDayCell(DateTime day, Color color) {
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        '${day.day}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, PeriodProvider period) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showDatePicker(context, period),
            icon: const Icon(Icons.add),
            label: const Text('Отметить начало'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.periodColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (period.latestRecord?.isOngoing == true) ...[
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _endPeriod(context, period),
              icon: const Icon(Icons.stop_rounded),
              label: const Text('Отметить конец'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.periodColor,
                side: const BorderSide(color: AppColors.periodColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCycleSettings(BuildContext context, PeriodProvider period) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настройки цикла',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Длина цикла'),
              Row(
                children: [
                  IconButton(
                    onPressed: period.cycleLength > 20
                        ? () =>
                            period.updateCycleLength(period.cycleLength - 1)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 20,
                  ),
                  Text(
                    '${period.cycleLength} дней',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: period.cycleLength < 45
                        ? () =>
                            period.updateCycleLength(period.cycleLength + 1)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Длительность'),
              Row(
                children: [
                  IconButton(
                    onPressed: period.periodDuration > 2
                        ? () => period
                            .updatePeriodDuration(period.periodDuration - 1)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 20,
                  ),
                  Text(
                    '${period.periodDuration} дней',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: period.periodDuration < 10
                        ? () => period
                            .updatePeriodDuration(period.periodDuration + 1)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomSection(BuildContext context, PeriodProvider period) {
    final symptoms = period.getSymptomsForDate(_selectedDay!);
    final symptomTypes = ['Боль', 'Спазм', 'Плохое настроение', 'Вздутие', 'Головная боль'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Симптомы - ${AppDateUtils.formatDateShort(_selectedDay!)}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                onPressed: () =>
                    _showAddSymptomDialog(context, period, symptomTypes),
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
              ),
            ],
          ),
          if (symptoms.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Нет записей на этот день',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            )
          else
            ...symptoms.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.periodColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s.symptom,
                        style: const TextStyle(
                          color: AppColors.periodColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < s.severity ? Icons.circle : Icons.circle_outlined,
                        size: 10,
                        color: AppColors.periodColor,
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

  Widget _buildCycleSummary(BuildContext context, PeriodProvider period) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Итоги цикла',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Средний цикл',
            value: '${period.averageCycleLength.toStringAsFixed(1)} дн.',
          ),
          _SummaryRow(
            label: 'Всего записей',
            value: '${period.records.length}',
          ),
          if (period.latestRecord != null)
            _SummaryRow(
              label: 'Прошлые месячные',
              value: AppDateUtils.formatDate(period.latestRecord!.startDate),
            ),
          if (period.nextPeriodDate != null)
            _SummaryRow(
              label: 'Прогноз следующих',
              value: AppDateUtils.formatDate(period.nextPeriodDate!),
            ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(
      BuildContext context, PeriodProvider period) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.periodColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      await period.addPeriodRecord(date);
    }
  }

  Future<void> _endPeriod(BuildContext context, PeriodProvider period) async {
    if (period.latestRecord == null) return;
    await period.endPeriod(period.latestRecord!.id, DateTime.now());
  }

  void _showAddSymptomDialog(
    BuildContext context,
    PeriodProvider period,
    List<String> symptomTypes,
  ) {
    String selectedSymptom = symptomTypes.first;
    int severity = 3;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Отметить симптом'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedSymptom,
                    items: symptomTypes
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      setDialogState(() => selectedSymptom = v!);
                    },
                    decoration:
                        const InputDecoration(labelText: 'Тип симптома'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Сила проявления'),
                  Slider(
                    value: severity.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: severity.toString(),
                    activeColor: AppColors.periodColor,
                    onChanged: (v) {
                      setDialogState(() => severity = v.round());
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    period.addSymptom(
                      date: _selectedDay!,
                      symptom: selectedSymptom,
                      severity: severity,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
