import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/haptic_utils.dart';
import '../../data/providers/blood_pressure_provider.dart';
import '../../data/providers/gamification_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bpProvider = context.watch<BloodPressureProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Давление и пульс')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Current stats
            if (bpProvider.latest != null)
              _buildCurrentStats(bpProvider)
                  .animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
            if (bpProvider.latest != null) const SizedBox(height: 20),

            // Log section
            _buildLogSection(context, bpProvider)
                .animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Chart
            if (bpProvider.records.length >= 2)
              _buildChart(bpProvider)
                  .animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            if (bpProvider.records.length >= 2) const SizedBox(height: 20),

            // History
            _buildHistory(bpProvider)
                .animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStats(BloodPressureProvider provider) {
    final record = provider.latest!;

    return GradientCard(
      gradient: const LinearGradient(
        colors: [Color(0xFFE57373), Color(0xFFC62828)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('Давление', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                '${record.systolic}/${record.diastolic}',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text('мм рт. ст.', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Column(
            children: [
              const Text('Пульс', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 20).animate(onPlay: (controller) => controller.repeat())
                      .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 600.ms, curve: Curves.easeInOut),
                  const SizedBox(width: 8),
                  Text(
                    '${record.pulse}',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Text('уд/мин', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogSection(BuildContext context, BloodPressureProvider provider) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Новая запись', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _systolicController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Сист. (верхнее)',
                    hintText: '120',
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('/', style: TextStyle(fontSize: 24, color: Colors.grey)),
              ),
              Expanded(
                child: TextFormField(
                  controller: _diastolicController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Диаст. (нижнее)',
                    hintText: '80',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pulseController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Пульс (уд/мин)',
              prefixIcon: Icon(Icons.favorite_border),
              hintText: '70',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _save(provider),
              icon: const Icon(Icons.add),
              label: const Text('Добавить запись'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BloodPressureProvider provider) {
    final records = provider.records.take(10).toList().reversed.toList();
    if (records.length < 2) return const SizedBox.shrink();

    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];
    final pulseSpots = <FlSpot>[];

    for (int i = 0; i < records.length; i++) {
      systolicSpots.add(FlSpot(i.toDouble(), records[i].systolic.toDouble()));
      diastolicSpots.add(FlSpot(i.toDouble(), records[i].diastolic.toDouble()));
      pulseSpots.add(FlSpot(i.toDouble(), records[i].pulse.toDouble()));
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Динамика показателей', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: _leftTitleWidgets,
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: systolicSpots,
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: diastolicSpots,
                    isCurved: true,
                    color: Colors.orangeAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: pulseSpots,
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Сист.', Colors.redAccent),
              const SizedBox(width: 15),
              _buildLegendItem('Диаст.', Colors.orangeAccent),
              const SizedBox(width: 15),
              _buildLegendItem('Пульс', Colors.blueAccent),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _leftTitleWidgets(double value, TitleMeta meta) {
    if (value % 20 != 0) return Container();
    return Text(
      value.toInt().toString(),
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHistory(BloodPressureProvider provider) {
    final records = provider.records.take(15).toList();
    if (records.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('История замеров', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...records.map((r) => GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.systolic}/${r.diastolic} мм рт. ст.',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(AppDateUtils.formatDateTime(r.date),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${r.pulse}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent)),
                      const Text('уд/мин', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _confirmDelete(provider, r.id),
                    icon: Icon(Icons.delete_outline, color: Colors.red.withValues(alpha: 0.5), size: 20),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _confirmDelete(BloodPressureProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить запись?'),
        content: const Text('Вы уверены, что хотите удалить эти показатели давления?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              provider.deleteRecord(id);
              Navigator.pop(ctx);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  void _save(BloodPressureProvider provider) {
    final sys = int.tryParse(_systolicController.text);
    final dia = int.tryParse(_diastolicController.text);
    final pulse = int.tryParse(_pulseController.text);

    if (sys == null || dia == null || pulse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля корректно')),
      );
      return;
    }

    HapticUtils.success();
    provider.addRecord(
      systolic: sys,
      diastolic: dia,
      pulse: pulse,
    );

    // Check achievement
    context.read<GamificationProvider>().checkBloodPressureAchievement(provider.records.length);

    _systolicController.clear();
    _diastolicController.clear();
    _pulseController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Показатели сохранены!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
