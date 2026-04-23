import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/haptic_utils.dart';
import '../../data/providers/weight_provider.dart';
import '../../data/providers/profile_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weight = context.watch<WeightProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Трекер веса и тела')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Current stats
            if (weight.latest != null)
              _buildCurrentStats(weight)
                  .animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
            if (weight.latest != null) const SizedBox(height: 20),

            // Log weight
            _buildLogSection(context, weight)
                .animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Chart
            if (weight.records.length >= 2)
              _buildChart(weight)
                  .animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            if (weight.records.length >= 2) const SizedBox(height: 20),

            // History
            _buildHistory(weight)
                .animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStats(WeightProvider weight) {
    final record = weight.latest!;
    final change = weight.weightChange;
    final profile = context.read<ProfileProvider>();
    
    // Расчет ИМТ на лету
    double? bmi;
    if (profile.height > 0) {
      final heightM = profile.height / 100;
      bmi = record.weight / (heightM * heightM);
    }

    return Column(
      children: [
        GradientCard(
          gradient: const LinearGradient(
            colors: [Color(0xFF26A69A), Color(0xFF00897B)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Текущий вес', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(
                      '${record.weight.toStringAsFixed(1)} кг',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(
                          change > 0 ? Icons.trending_up : change < 0 ? Icons.trending_down : Icons.trending_flat,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${change > 0 ? "+" : ""}${change.toStringAsFixed(1)} кг',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const Text(' с прошлого раза', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              if (record.waistToHipRatio != null)
                Column(
                  children: [
                    const Text('Талия/Бёдра', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    Text(
                      record.waistToHipRatio!.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (bmi != null) ...[
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                const Text('Ваш индекс массы тела (ИМТ)', 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _buildMiniGauge(bmi),
                Text(
                  _getBmiCategory(bmi),
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: _getBmiColor(bmi)
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMiniGauge(double bmi) {
    final color = _getBmiColor(bmi);
    return SizedBox(
      height: 140,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 10,
            maximum: 45,
            startAngle: 180,
            endAngle: 0,
            showLabels: false,
            showTicks: false,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.2,
              cornerStyle: CornerStyle.bothCurve,
              color: Color(0xFFE0E0E0),
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: bmi.clamp(10, 45),
                width: 0.2,
                sizeUnit: GaugeSizeUnit.factor,
                color: color,
                cornerStyle: CornerStyle.bothCurve,
              ),
              MarkerPointer(
                value: bmi.clamp(10, 45),
                markerType: MarkerType.circle,
                color: Colors.white,
                markerHeight: 15,
                markerWidth: 15,
                borderWidth: 2,
                borderColor: color,
              )
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  bmi.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                angle: 90,
                positionFactor: 0.5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogSection(BuildContext context, WeightProvider weight) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Запись за сегодня', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Вес (кг)',
              prefixIcon: Icon(Icons.monitor_weight),
              hintText: '55.5',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _waistController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Талия (см)',
                    prefixIcon: Icon(Icons.straighten),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _hipController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Бедра (см)',
                    prefixIcon: Icon(Icons.straighten),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _save(weight),
              icon: const Icon(Icons.save),
              label: const Text('Сохранить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bmiColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(WeightProvider weight) {
    final data = weight.monthlyData;
    if (data.isEmpty) return const SizedBox.shrink();

    final spots = data.map((d) =>
        FlSpot((d['день'] as int).toDouble(), d['вес'] as double)).toList();
    final minW = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxW = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: AppColors.bmiColor, size: 20),
              SizedBox(width: 8),
              Text('Тренд веса', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) =>
                          Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, _) =>
                          Text('${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: minW,
                maxY: maxW,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(colors: [AppColors.bmiColor, Color(0xFF00897B)]),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.bmiColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppColors.bmiColor.withValues(alpha: 0.3), AppColors.bmiColor.withValues(alpha: 0.0)],
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

  Widget _buildHistory(WeightProvider weight) {
    final records = weight.records.take(10).toList();
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
                  const Icon(Icons.monitor_weight, color: AppColors.bmiColor),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.weight.toStringAsFixed(1)} кг',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(AppDateUtils.formatDate(r.date),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  if (r.waist != null)
                    Text('Талия: ${r.waist!.toStringAsFixed(0)} см',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  if (r.hip != null)
                    Text(' Бедра: ${r.hip!.toStringAsFixed(0)} см',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            )),
      ],
    );
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Дефицит';
    if (bmi < 24.9) return 'Норма';
    if (bmi < 29.9) return 'Чуть выше нормы';
    return 'Ожирение';
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return AppColors.info;
    if (bmi < 24.9) return AppColors.success;
    if (bmi < 29.9) return AppColors.warning;
    return AppColors.error;
  }

  void _save(WeightProvider weight) {
    final w = double.tryParse(_weightController.text);
    if (w == null || w <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите допустимый вес')),
      );
      return;
    }
    HapticUtils.success();
    weight.addRecord(
      weight: w,
      waist: double.tryParse(_waistController.text),
      hip: double.tryParse(_hipController.text),
    );
    _weightController.clear();
    _waistController.clear();
    _hipController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Вес зафиксирован!'),
        backgroundColor: AppColors.bmiColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
