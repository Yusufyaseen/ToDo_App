import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices {
  final GetStorage _box = GetStorage();
  final String _key = "isDarkMode";
  _saveMode(bool mode) => _box.write(_key, mode);
  bool _currentTheme() => _box.read(_key) ?? false;
  ThemeMode get theme => _currentTheme() ? ThemeMode.dark : ThemeMode.light;
  void switchTheme() {
    Get.changeThemeMode(_currentTheme() ? ThemeMode.light : ThemeMode.dark);
    _saveMode(!_currentTheme());
  }
}
