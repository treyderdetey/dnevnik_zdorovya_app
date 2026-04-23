import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/medicine_model.dart';
import '../../data/providers/medicine_provider.dart';

class MedicineReminderScreen extends StatelessWidget {
  const MedicineReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicineProvider>();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Напоминания',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Отслеживайте прием лекарств',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              _buildProgressCard(context, provider),
              const SizedBox(height: 24),

              if (provider.todayDoses.isNotEmpty) ...[
                const Text(
                  "Расписание на сегодня",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.todayDoses.map(
                  (dose) => _buildDoseCard(context, dose, provider),
                ),
                const SizedBox(height: 24),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Мои лекарства',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showMedicineDialog(context, provider),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Добавить'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (provider.medicines.isEmpty)
                _buildEmptyState()
              else
                ...provider.medicines
                    .map((m) => _buildMedicineCard(context, m, provider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, MedicineProvider provider) {
    final rate = provider.todayCompletionRate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.medicineColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Прогресс на сегодня",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Принято ${provider.todayTakenCount} из ${provider.todayTotalCount}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: rate,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${(rate * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoseCard(
    BuildContext context,
    MedicineDose dose,
    MedicineProvider provider,
  ) {
    final name = provider.getMedicineName(dose.medicineId);
    final isPast = dose.scheduledTime.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dose.taken
              ? AppColors.success.withValues(alpha: 0.4)
              : isPast
                  ? AppColors.error.withValues(alpha: 0.4)
                  : Colors.grey.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: dose.taken
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.medicineColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              dose.taken ? Icons.check_circle : Icons.medication,
              color: dose.taken ? AppColors.success : AppColors.medicineColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    decoration: dose.taken ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppDateUtils.formatTime(dose.scheduledTime),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!dose.taken) ...[
            IconButton(
              onPressed: () => provider.markDoseTaken(dose.id),
              icon: const Icon(Icons.check_circle_outline),
              color: AppColors.success,
              tooltip: 'Отметить как принятое',
            ),
            IconButton(
              onPressed: () => provider.markDoseMissed(dose.id),
              icon: const Icon(Icons.cancel_outlined),
              color: AppColors.error,
              tooltip: 'Пропустить',
            ),
          ] else
            const Chip(
              label: Text('Принято', style: TextStyle(fontSize: 12)),
              backgroundColor: Color(0xFFE8F5E9),
              labelStyle: TextStyle(color: AppColors.success),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(
    BuildContext context,
    MedicineModel medicine,
    MedicineProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: medicine.isActive
                      ? AppColors.medicineColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medication_rounded,
                  color: medicine.isActive
                      ? AppColors.medicineColor
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (medicine.dosage != null)
                      Text(
                        medicine.dosage!,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              Switch(
                value: medicine.isActive,
                onChanged: (_) =>
                    provider.toggleMedicineActive(medicine.id),
                activeTrackColor: AppColors.medicineColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: medicine.times
                .map(
                  (t) => Chip(
                    label: Text(t, style: const TextStyle(fontSize: 12)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _showMedicineDialog(context, provider, medicine: medicine),
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: Colors.blue,
                tooltip: 'Редактировать',
              ),
              IconButton(
                onPressed: () => _confirmDelete(context, medicine, provider),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
                tooltip: 'Удалить',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.medication_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Лекарства не добавлены',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMedicineDialog(
    BuildContext context,
    MedicineProvider provider, {
    MedicineModel? medicine,
  }) {
    final nameController = TextEditingController(text: medicine?.name);
    final dosageController = TextEditingController(text: medicine?.dosage);
    final notesController = TextEditingController(text: medicine?.notes);
    
    List<TimeOfDay> selectedTimes = [];
    if (medicine != null) {
      selectedTimes = medicine.times.map((t) {
        final parts = t.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList();
    } else {
      selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
    }

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
                24,
                24,
                24,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine == null ? 'Добавить лекарство' : 'Редактировать',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Название',
                          prefixIcon: Icon(Icons.medication),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Обязательно' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: dosageController,
                        decoration: const InputDecoration(
                          labelText: 'Дозировка (необязательно)',
                          prefixIcon: Icon(Icons.straighten),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Время напоминания', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...selectedTimes.asMap().entries.map((entry) {
                            final i = entry.key;
                            final time = entry.value;
                            return InputChip(
                              label: Text(time.format(ctx)),
                              onPressed: () async {
                                final picked = await showTimePicker(context: ctx, initialTime: time);
                                if (picked != null) setSheetState(() => selectedTimes[i] = picked);
                              },
                              onDeleted: selectedTimes.length > 1 ? () => setSheetState(() => selectedTimes.removeAt(i)) : null,
                            );
                          }),
                          ActionChip(
                            label: const Text('Добавить'),
                            avatar: const Icon(Icons.add, size: 16),
                            onPressed: () async {
                              final picked = await showTimePicker(context: ctx, initialTime: const TimeOfDay(hour: 12, minute: 0));
                              if (picked != null) setSheetState(() => selectedTimes.add(picked));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            final times = selectedTimes.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').toList();
                            
                            if (medicine == null) {
                              provider.addMedicine(
                                name: nameController.text.trim(),
                                dosage: dosageController.text.trim(),
                                times: times,
                                notes: notesController.text.trim(),
                              );
                            } else {
                              provider.updateMedicine(
                                id: medicine.id,
                                name: nameController.text.trim(),
                                dosage: dosageController.text.trim(),
                                times: times,
                                notes: notesController.text.trim(),
                              );
                            }
                            Navigator.pop(ctx);
                          },
                          child: const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, MedicineModel medicine, MedicineProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить?'),
        content: Text('Удалить "${medicine.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              provider.deleteMedicine(medicine.id);
              Navigator.pop(ctx);
            },
            child: const Text('Удалить', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
