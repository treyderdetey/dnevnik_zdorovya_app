import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/providers/blood_pressure_provider.dart';
import '../../data/providers/medicine_provider.dart';
import '../../data/providers/mood_provider.dart';
import '../../data/providers/period_provider.dart';
import '../../data/providers/profile_provider.dart';
import '../../data/providers/sleep_provider.dart';
import '../../data/providers/water_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_card.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  // Состояния для переключателей разделов отчета
  bool _includePersonalInfo = true;
  bool _includePeriod = true;
  bool _includeMedicine = true;
  bool _includeWater = true;
  bool _includeSleep = true;
  bool _includeMood = true;
  bool _includeBP = true;
  bool _includeSos = true;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final isFemale = profile.isFemale;

    return Scaffold(
      appBar: AppBar(title: const Text('Состояние здоровья')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            GradientCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
              ),
              child: const Column(
                children: [
                  Icon(Icons.description_rounded, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Экспорт состояния здоровья',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Создайте PDF-сводку ваших медицинских данных,\n чтобы поделиться ею с врачом.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 24),

            // What's included
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Настройка разделов отчета', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildIncludeItem(
                    Icons.person,
                    'Персональная информация',
                    _includePersonalInfo,
                    (v) => setState(() => _includePersonalInfo = v),
                  ),
                  if (isFemale)
                    _buildIncludeItem(
                      Icons.favorite,
                      'История цикла',
                      _includePeriod,
                      (v) => setState(() => _includePeriod = v),
                    ),
                  _buildIncludeItem(
                    Icons.medication,
                    'График приема лекарств',
                    _includeMedicine,
                    (v) => setState(() => _includeMedicine = v),
                  ),
                  _buildIncludeItem(
                    Icons.water_drop,
                    'Сводка выпитой воды',
                    _includeWater,
                    (v) => setState(() => _includeWater = v),
                  ),
                  _buildIncludeItem(
                    Icons.bedtime,
                    'Анализ паттернов сна',
                    _includeSleep,
                    (v) => setState(() => _includeSleep = v),
                  ),
                  _buildIncludeItem(
                    Icons.emoji_emotions,
                    'Отчет о настроении',
                    _includeMood,
                    (v) => setState(() => _includeMood = v),
                  ),
                  _buildIncludeItem(
                    Icons.monitor_heart,
                    'Давление и пульс',
                    _includeBP,
                    (v) => setState(() => _includeBP = v),
                  ),
                  _buildIncludeItem(
                    Icons.sos_rounded,
                    'Медицинская инфо и SOS',
                    _includeSos,
                    (v) => setState(() => _includeSos = v),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _generateAndPreview(context),
                icon: const Icon(Icons.picture_as_pdf, size: 24),
                label: const Text('Создать PDF-отчёт', style: TextStyle(fontSize: 17)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),

            // Share button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _shareReport(context),
                icon: const Icon(Icons.share, size: 24),
                label: const Text('Поделиться / Печать отчета', style: TextStyle(fontSize: 17)),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildIncludeItem(IconData icon, String text, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndPreview(BuildContext context) async {
    final pdf = await _buildPdf(context);

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Предварительный отчет')),
          body: PdfPreview(
            build: (_) => pdf,
            canChangePageFormat: false,
            canChangeOrientation: false,
          ),
        ),
      ),
    );
  }

  Future<void> _shareReport(BuildContext context) async {
    final pdf = await _buildPdf(context);
    await Printing.sharePdf(bytes: pdf, filename: 'отчет_о_здоровье.pdf');
  }

  Future<Uint8List> _buildPdf(BuildContext context) async {
    final profile = context.read<ProfileProvider>();
    final period = context.read<PeriodProvider>();
    final medicine = context.read<MedicineProvider>();
    final water = context.read<WaterProvider>();
    final sleep = context.read<SleepProvider>();
    final mood = context.read<MoodProvider>();
    final bp = context.read<BloodPressureProvider>();
    final settingsBox = Hive.box(AppConstants.settingsBox);

    // Load font for Cyrillic support
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final theme = pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
    );

    final doc = pw.Document(theme: theme);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Здоровье',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text('Отчет о здоровье',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
              ],
            ),
            pw.Divider(),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Дата создания: ${AppDateUtils.formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
            pw.Text('Страница ${ctx.pageNumber} из ${ctx.pagesCount}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
          ],
        ),
        build: (ctx) => [
          // Personal info
          if (_includePersonalInfo) ...[
            _pdfSection('Персональные данные', [
              _pdfRow('Имя', profile.name.isNotEmpty ? profile.name : 'Не указано'),
              _pdfRow('Возраст', profile.age > 0 ? '${profile.age} лет' : 'Не указано'),
              _pdfRow('Пол', profile.isFemale ? 'Женский' : 'Мужской'),
              _pdfRow('Дата отчета', AppDateUtils.formatDate(DateTime.now())),
            ]),
            pw.SizedBox(height: 16),
          ],

          // SOS & Medical Info
          if (_includeSos) ...[
            _buildSosPdfSection(settingsBox),
            pw.SizedBox(height: 16),
          ],

          // Period tracking
          if (profile.isFemale && _includePeriod) ...[
            _pdfSection('Отслеживание цикла', [
              _pdfRow('Длина цикла', '${period.cycleLength} дней'),
              _pdfRow('Средний цикл', '${period.averageCycleLength.toStringAsFixed(1)} дней'),
              _pdfRow('Всего записей', '${period.records.length}'),
              if (period.nextPeriodDate != null)
                _pdfRow('Следующий прогноз', AppDateUtils.formatDate(period.nextPeriodDate!)),
              if (period.latestRecord != null)
                _pdfRow('Последние месячные', AppDateUtils.formatDate(period.latestRecord!.startDate)),
            ]),
            pw.SizedBox(height: 16),
          ],

          // Medicine
          if (_includeMedicine) ...[
            _pdfSection('Управление лекарствами', [
              _pdfRow('Активных лекарств', '${medicine.activeMedicines.length}'),
              _pdfRow('Приверженность сегодня',
                  '${(medicine.todayCompletionRate * 100).round()}%'),
              ...medicine.activeMedicines.map(
                    (m) => _pdfRow(
                  '  ${m.name}',
                  '${m.dosage ?? ""} в ${m.times.join(", ")}',
                ),
              ),
            ]),
            pw.SizedBox(height: 16),
          ],

          // Water
          if (_includeWater) ...[
            _pdfSection('Водный баланс', [
              _pdfRow('Дневная норма', '${water.dailyGoal} стаканов (${water.goalMl} мл)'),
              _pdfRow('Выпито сегодня', '${water.todayGlasses} стаканов (${water.todayMl} мл)'),
              _pdfRow('Прогресс', '${(water.todayProgress * 100).round()}%'),
            ]),
            pw.SizedBox(height: 16),
          ],

          // Sleep
          if (_includeSleep) ...[
            _pdfSection('Сон', [
              _pdfRow('Средняя длительность', '${sleep.averageDuration.toStringAsFixed(1)} часов'),
              _pdfRow('Среднее качество', '${sleep.averageQuality.toStringAsFixed(1)} / 5'),
              _pdfRow('Всего записей', '${sleep.records.length}'),
              if (sleep.lastNight != null)
                _pdfRow('Прошлая ночь', sleep.lastNight!.durationFormatted),
            ]),
            pw.SizedBox(height: 16),
          ],

          // Mood
          if (_includeMood) ...[
            _pdfSection('Настроение', [
              _pdfRow('Средний уровень', '${mood.averageMoodScore.toStringAsFixed(1)} / 5'),
              _pdfRow('Текущая серия записей', '${mood.moodStreak} дней'),
              _pdfRow('Всего записей', '${mood.entries.length}'),
            ]),
            pw.SizedBox(height: 16),
          ],

          // Blood Pressure
          if (_includeBP) ...[
            _pdfSection('Давление и пульс', [
              if (bp.latest != null) ...[
                _pdfRow('Последний замер', '${bp.latest!.systolic}/${bp.latest!.diastolic} мм рт. ст.'),
                _pdfRow('Пульс', '${bp.latest!.pulse} уд/мин'),
                _pdfRow('Дата последнего замера', AppDateUtils.formatDateTime(bp.latest!.date)),
              ] else
                pw.Text('Нет записей', style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
              _pdfRow('Всего записей', '${bp.records.length}'),
            ]),
            pw.SizedBox(height: 24),
          ],

          // Disclaimer
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'Отказ от ответственности: Этот отчёт сформирован на основе данных, введённых пользователем, и носит исключительно информационный характер. '
                  'Он не должен использоваться как замена профессиональной медицинской консультации, диагностики или лечения.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    return Uint8List.fromList(await doc.save());
  }

  pw.Widget _pdfSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        ...children,
      ],
    );
  }

  pw.Widget _buildSosPdfSection(Box box) {
    final medicalInfo = box.get('медицинская информация', defaultValue: '') as String;
    final rawContacts = box.get('экстренные контакты', defaultValue: <dynamic>[]) as List;

    if (medicalInfo.isEmpty && rawContacts.isEmpty) return pw.SizedBox.shrink();

    return _pdfSection('Экстренная информация', [
      if (medicalInfo.isNotEmpty) ...[
        pw.Text('Медицинская информация:',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 4, top: 2, bottom: 6),
          child: pw.Text(medicalInfo, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
      if (rawContacts.isNotEmpty) ...[
        pw.Text('Экстренные контакты:',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ...rawContacts.map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          final name = (map['name'] ?? map['имя'] ?? 'Без имени').toString();
          final phone = (map['phone'] ?? map['телефон'] ?? '').toString();
          return _pdfRow('  $name', phone);
        }),
      ],
    ]);
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
