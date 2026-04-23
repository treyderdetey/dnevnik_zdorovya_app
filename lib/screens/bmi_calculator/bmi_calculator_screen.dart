import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/haptic_utils.dart';
import '../../data/providers/profile_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  double _height = 165; // cm
  double _weight = 60; // kg
  double? _bmi;
  String _category = '';
  Color _categoryColor = AppColors.bmiColor;
  String _healthTip = '';

  void _calculateBMI() {
    HapticUtils.mediumTap();
    final heightM = _height / 100;
    final bmi = _weight / (heightM * heightM);
    setState(() {
      _bmi = bmi;
      _updateCategory(bmi);
    });
  }

  void _updateCategory(double bmi) {
    if (bmi < 18.5) {
      _category = 'Дефицит';
      _categoryColor = AppColors.info;
      _healthTip =
          'Вам требуется набрать вес. Добавьте в рацион продукты, богатые белком, полезные жиры и ешьте чаще.';
    } else if (bmi < 24.9) {
      _category = 'Норма';
      _categoryColor = AppColors.success;
      _healthTip =
          'Отличная работа! Поддерживайте здоровый вес с помощью сбалансированного питания и регулярных физических нагрузок.';
    } else if (bmi < 29.9) {
      _category = 'Чуть выше нормы';
      _categoryColor = AppColors.warning;
      _healthTip =
          'Рассмотрите возможность увеличить физическую активность и снизить потребление калорий. Небольшие изменения дают большой результат.';
    } else {
      _category = 'Ожирение';
      _categoryColor = AppColors.error;
      _healthTip =
          'Проконсультируйтесь с медицинским специалистом. Сосредоточьтесь на постепенных изменениях образа жизни — питании, физической активности и сне.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isFemale = profileProvider.isFemale;

    return Scaffold(
      appBar: AppBar(title: const Text('Калькулятор ИМТ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Height slider
            GlassCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Рост',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${_height.round()} см',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.bmiColor,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _height,
                    min: 100,
                    max: 220,
                    divisions: 120,
                    activeColor: AppColors.bmiColor,
                    onChanged: (v) {
                      HapticUtils.selection();
                      setState(() => _height = v);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('100 см', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      Text('220 см', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 16),

            // Weight slider
            GlassCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Вес',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${_weight.round()} кг',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.bmiColor,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _weight,
                    min: 30,
                    max: 200,
                    divisions: 170,
                    activeColor: AppColors.bmiColor,
                    onChanged: (v) {
                      HapticUtils.selection();
                      setState(() => _weight = v);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('30 кг', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      Text('200 кг', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),

            // Calculate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bmiColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Рассчитать ИМТ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 30),

            // Result
            if (_bmi != null) ...[
              // Gauge
              _buildGauge().animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    curve: Curves.elasticOut,
                    duration: 800.ms,
                  ),
              const SizedBox(height: 20),

              // Result card
              GradientCard(
                gradient: LinearGradient(
                  colors: [
                    _categoryColor,
                    _categoryColor.withValues(alpha: 0.7),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _bmi!.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _healthTip,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),
              const SizedBox(height: 16),

              // Ideal weight range
              GlassCard(
                child: Column(
                  children: [
                    const Text(
                      'Идеальный диапазон веса',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _idealWeightRange(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      'Исходя из вашего роста ${_height.round()} см',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Рекомендуемый идеальный вес',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_calculateIdealBodyWeight(isFemale).toStringAsFixed(1)} кг',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bmiColor,
                      ),
                    ),
                    Text(
                      'Расчет по формулам Робинсона и Миллера для ${isFemale ? 'женщин' : 'мужчин'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ],
        ),
      ),
    );
  }

  double _calculateIdealBodyWeight(bool isFemale) {
    final heightIn = _height / 2.54;
    final inchesOver5ft = heightIn - 60;

    // Robinson Formula
    double robinson;
    if (inchesOver5ft < 0) {
      robinson = isFemale ? 49.0 : 52.0;
    } else {
      robinson = isFemale ? 49 + (1.7 * inchesOver5ft) : 52 + (1.9 * inchesOver5ft);
    }

    // Miller Formula
    double miller;
    if (inchesOver5ft < 0) {
      miller = isFemale ? 53.1 : 56.2;
    } else {
      miller = isFemale ? 53.1 + (1.36 * inchesOver5ft) : 56.2 + (1.41 * inchesOver5ft);
    }

    // Return average of both
    return (robinson + miller) / 2;
  }

  Widget _buildGauge() {
    return SizedBox(
      height: 250,
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        animationDuration: 1500,
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 10,
            maximum: 45,
            startAngle: 150,
            endAngle: 30,
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: 10,
                endValue: 18.5,
                color: AppColors.info,
                label: 'Ниже',
                labelStyle: const GaugeTextStyle(fontSize: 10, color: Colors.white),
              ),
              GaugeRange(
                startValue: 18.5,
                endValue: 24.9,
                color: AppColors.success,
                label: 'Норма',
                labelStyle: const GaugeTextStyle(fontSize: 10, color: Colors.white),
              ),
              GaugeRange(
                startValue: 24.9,
                endValue: 29.9,
                color: AppColors.warning,
                label: 'Выше',
                labelStyle: const GaugeTextStyle(fontSize: 10, color: Colors.white),
              ),
              GaugeRange(
                startValue: 29.9,
                endValue: 45,
                color: AppColors.error,
                label: 'Ожирение',
                labelStyle: const GaugeTextStyle(fontSize: 10, color: Colors.white),
              ),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                value: _bmi!.clamp(10, 45),
                enableAnimation: true,
                animationDuration: 1200,
                animationType: AnimationType.elasticOut,
                needleColor: _categoryColor,
                needleLength: 0.7,
                knobStyle: KnobStyle(
                  color: _categoryColor,
                  borderColor: Colors.white,
                  borderWidth: 0.02,
                  knobRadius: 0.06,
                ),
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  _bmi!.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _categoryColor,
                  ),
                ),
                angle: 90,
                positionFactor: 0.45,
              ),
            ],
            axisLabelStyle: const GaugeTextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _idealWeightRange() {
    final heightM = _height / 100;
    final minWeight = (18.5 * heightM * heightM).toStringAsFixed(1);
    final maxWeight = (24.9 * heightM * heightM).toStringAsFixed(1);
    return '$minWeight - $maxWeight кг';
  }
}
