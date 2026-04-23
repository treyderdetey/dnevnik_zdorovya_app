class AppConstants {
  AppConstants._();

  // Hive box names
  static const String periodBox = 'period_records';
  static const String symptomsBox = 'symptom_entries';
  static const String medicineBox = 'medicines';
  static const String medicineDoseBox = 'medicine_doses';
  static const String waterBox = 'water_intake';
  static const String settingsBox = 'settings';
  static const String profileBox = 'profile';
  static const String moodBox = 'mood_entries';
  static const String streakBox = 'streaks';
  static const String sleepBox = 'sleep_records';
  static const String challengeBox = 'challenges';
  static const String achievementBox = 'achievements';
  static const String weightBox = 'weight_records';
  static const String habitBox = 'habits';
  static const String habitCompletionBox = 'habit_completions';
  static const String bloodPressureBox = 'blood_pressure_records';

  // Theme
  static const String keyCustomTheme = 'custom_theme';

  // Emergency contacts
  static const String keyEmergencyContacts = 'emergency_contacts';
  static const String keyLanguage = 'language';

  // Settings keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyCycleLength = 'cycle_length';
  static const String keyPeriodDuration = 'period_duration';
  static const String keyWaterGoal = 'water_goal';
  static const String keyWaterReminderInterval = 'water_reminder_interval';
  static const String keyWaterReminderEnabled = 'water_reminder_enabled';

  // Profile keys
  static const String keyName = 'name';
  static const String keyAge = 'age';
  static const String keyGender = 'gender';
  static const String keyHeight = 'height';

  // Gender values
  static const String genderFemale = 'female';
  static const String genderMale = 'male';
  static const String genderOther = 'other';

  // Default values
  static const int defaultCycleLength = 28;
  static const int defaultPeriodDuration = 5;
  static const int defaultWaterGoal = 8; // glasses
  static const int defaultWaterReminderInterval = 2; // hours
  static const int waterGlassMl = 250;

  // Notification channel
  static const String medicineChannelId = 'medicine_reminders_v4';
  static const String medicineChannelName = 'Напоминания о лекарствах';
  static const String waterChannelId = 'water_reminders_v4';
  static const String waterChannelName = 'Напоминания о воде';
  static const String periodChannelId = 'period_reminders_v4';
  static const String periodChannelName = 'Женский календарь';
}
