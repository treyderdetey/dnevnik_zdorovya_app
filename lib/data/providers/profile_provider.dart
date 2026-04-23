import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

class ProfileProvider extends ChangeNotifier {
  late Box _profileBox;
  late Box _settingsBox;

  String _name = '';
  int _age = 0;
  double _height = 0;
  String _gender = AppConstants.genderFemale;
  bool _onboardingDone = false;

  ProfileProvider() {
    _profileBox = Hive.box(AppConstants.profileBox);
    _settingsBox = Hive.box(AppConstants.settingsBox);
    _loadProfile();
  }

  String get name => _name;
  int get age => _age;
  double get height => _height;
  String get gender => _gender;
  bool get isFemale => _gender == AppConstants.genderFemale;
  bool get onboardingDone => _onboardingDone;

  void _loadProfile() {
    _name = _profileBox.get(AppConstants.keyName, defaultValue: '');
    _age = _profileBox.get(AppConstants.keyAge, defaultValue: 0);
    _height = (_profileBox.get(AppConstants.keyHeight, defaultValue: 0) as num).toDouble();
    _gender = _profileBox.get(AppConstants.keyGender, defaultValue: AppConstants.genderFemale);
    _onboardingDone = _settingsBox.get(AppConstants.keyOnboardingDone, defaultValue: false);
    notifyListeners();
  }

  Future<void> updateProfile({required String name, required int age, required double height, String? gender}) async {
    _name = name;
    _age = age;
    _height = height;
    if (gender != null) _gender = gender;
    
    await _profileBox.put(AppConstants.keyName, name);
    await _profileBox.put(AppConstants.keyAge, age);
    await _profileBox.put(AppConstants.keyHeight, height);
    if (gender != null) await _profileBox.put(AppConstants.keyGender, gender);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    await _settingsBox.put(AppConstants.keyOnboardingDone, true);
    notifyListeners();
  }
}
