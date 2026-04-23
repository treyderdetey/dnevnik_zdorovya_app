import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_constants.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_service.dart';
import 'data/models/blood_pressure_model.dart';
import 'data/models/challenge_model.dart';
import 'data/models/habit_model.dart';
import 'data/models/medicine_model.dart';
import 'data/models/mood_model.dart';
import 'data/models/period_model.dart';
import 'data/models/sleep_model.dart';
import 'data/models/streak_model.dart';
import 'data/models/water_model.dart';
import 'data/models/weight_model.dart';
import 'data/providers/blood_pressure_provider.dart';
import 'data/providers/gamification_provider.dart';
import 'data/providers/habit_provider.dart';
import 'data/providers/medicine_provider.dart';
import 'data/providers/mood_provider.dart';
import 'data/providers/period_provider.dart';
import 'data/providers/profile_provider.dart';
import 'data/providers/sleep_provider.dart';
import 'data/providers/streak_provider.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/water_provider.dart';
import 'data/providers/weight_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Text(
              'FATAL ERROR:\n${details.exception}\n\nSTACK:\n${details.stack}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
      ),
    );
  };

  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('ru_RU', null);
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();

    try {
      await NotificationService.instance.init();
    } catch (e) {
      debugPrint('Notification Service init error: $e');
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(const DnevnikZdorovyaApp());
  } catch (e, stack) {
    debugPrint('FATAL ERROR DURING INIT: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Fatal Initialization Error: $e')),
      ),
    ));
  }
}

void _registerAdapters() {
  Hive.registerAdapter(PeriodRecordAdapter());
  Hive.registerAdapter(SymptomEntryAdapter());
  Hive.registerAdapter(MedicineModelAdapter());
  Hive.registerAdapter(MedicineDoseAdapter());
  Hive.registerAdapter(WaterIntakeAdapter());
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(StreakModelAdapter());
  Hive.registerAdapter(SleepRecordAdapter());
  Hive.registerAdapter(DailyChallengeAdapter());
  Hive.registerAdapter(UserAchievementAdapter());
  Hive.registerAdapter(WeightRecordAdapter());
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(HabitCompletionAdapter());
  Hive.registerAdapter(BloodPressureRecordAdapter());
}

Future<void> _openBoxes() async {
  await Hive.openBox<PeriodRecord>(AppConstants.periodBox);
  await Hive.openBox<SymptomEntry>(AppConstants.symptomsBox);
  await Hive.openBox<MedicineModel>(AppConstants.medicineBox);
  await Hive.openBox<MedicineDose>(AppConstants.medicineDoseBox);
  await Hive.openBox<WaterIntake>(AppConstants.waterBox);
  await Hive.openBox<MoodEntry>(AppConstants.moodBox);
  await Hive.openBox<StreakModel>(AppConstants.streakBox);
  await Hive.openBox<SleepRecord>(AppConstants.sleepBox);
  await Hive.openBox<DailyChallenge>(AppConstants.challengeBox);
  await Hive.openBox<UserAchievement>(AppConstants.achievementBox);
  await Hive.openBox<WeightRecord>(AppConstants.weightBox);
  await Hive.openBox<HabitModel>(AppConstants.habitBox);
  await Hive.openBox<HabitCompletion>(AppConstants.habitCompletionBox);
  await Hive.openBox<BloodPressureRecord>(AppConstants.bloodPressureBox);
  await Hive.openBox(AppConstants.settingsBox);
  await Hive.openBox(AppConstants.profileBox);
}

class DnevnikZdorovyaApp extends StatelessWidget {
  const DnevnikZdorovyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PeriodProvider()),
        ChangeNotifierProxyProvider<GamificationProvider, MedicineProvider>(
          create: (_) => MedicineProvider(),
          update: (_, gamification, medicine) => medicine!..updateGamification(gamification),
        ),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProxyProvider<GamificationProvider, WaterProvider>(
          create: (_) => WaterProvider(),
          update: (_, gamification, water) => water!..updateGamification(gamification),
        ),
        ChangeNotifierProxyProvider<GamificationProvider, MoodProvider>(
          create: (_) => MoodProvider(),
          update: (_, gamification, mood) => mood!..updateGamification(gamification),
        ),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
        ChangeNotifierProxyProvider<GamificationProvider, SleepProvider>(
          create: (_) => SleepProvider(),
          update: (_, gamification, sleep) => sleep!..updateGamification(gamification),
        ),
        ChangeNotifierProvider(create: (_) => WeightProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => BloodPressureProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Ассистент Здоровья',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.createTheme(
              brightness: Brightness.light,
              seedColor: themeProvider.accentColor,
            ),
            darkTheme: AppTheme.createTheme(
              brightness: Brightness.dark,
              seedColor: themeProvider.accentColor,
            ),
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ru'),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
