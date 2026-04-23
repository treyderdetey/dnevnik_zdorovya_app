import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {

    'ru': {
      'app_name': 'Ассистент Здоровья',
      'home': 'Главная',
      'period': 'Цикл',
      'mood': 'Настроение',
      'reminders': 'Напоминания',
      'profile': 'Профиль',
      'good_morning': 'Доброе утро',
      'good_afternoon': 'Добрый день',
      'good_evening': 'Добрый вечер',
      'welcome': 'Добро пожаловать!',
      'period_tracker': 'Трекер цикла',
      'medicine_reminders': 'Напоминания о лекарствах',
      'water_tracker': 'Трекер воды',
      'sleep_tracker': 'Трекер сна',
      'health_tips': 'Советы по здоровью',
      'settings': 'Настройки',
      'dark_mode': 'Темная тема',
      'light_mode': 'Светлая тема',
      'language': 'Язык',
      'about': 'О приложении',
      'bmi_calculator': 'Калькулятор ИМТ',
      'analytics': 'Аналитика здоровья',
      'emergency_sos': 'Экстренный SOS',
      'export_report': 'Отчет о здоровье',
      'challenges': 'Челенджи и награды',
      'glasses': 'стаканов',
      'days': 'дней',
      'taken': 'Принято',
      'missed': 'Пропущено',
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'delete': 'Удалить',
      'add': 'Добавить',
      'edit': 'Изменить',
      'name': 'Имя',
      'age': 'Возраст',
      'cycle_length': 'Длина цикла',
      'period_duration': 'Длительность периода',
      'daily_goal': 'Дневная цель',
      'how_are_you': 'Как вы себя чувствуете?',
      'log_sleep': 'Записать сон',
      'bedtime': 'Время сна',
      'wake_up': 'Время подъема',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static List<Locale> get supportedLocales => const [

        Locale('ru', '')
      ];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
