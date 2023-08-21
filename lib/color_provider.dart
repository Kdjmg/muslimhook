import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  ColorProvider(this._prefs);
  late Color _selectedSvgColor = Colors.blueAccent;
  late Color _selectedTextColor = Colors.blueAccent;
  late Color _selectedBackgroundColor = Colors.blueAccent;

  Color get selectedSvgColor => _selectedSvgColor;
  Color get selectedTextColor => _selectedTextColor;
  Color get selectedBackgroundColor => _selectedBackgroundColor;

 Future<void> loadSavedColors() async {
    _selectedSvgColor = Color(_prefs.getInt('selectedSvgColor') ?? Colors.blueAccent.value);
    _selectedTextColor = Color(_prefs.getInt('selectedTextColor') ?? Colors.black.value);
    _selectedBackgroundColor = Color(_prefs.getInt('selectedBackgroundColor') ?? Colors.white.value);
    notifyListeners();
  }

  Future<void> setSelectedSvgColor(Color color) async {
    _selectedSvgColor = color;
    _prefs.setInt('selectedSvgColor', color.value);
    notifyListeners();
  }

  Future<void> setSelectedTextColor(Color color) async {
    _selectedTextColor = color;
    _prefs.setInt('selectedTextColor', color.value);
    notifyListeners();
  }

  Future<void> setSelectedBackgroundColor(Color color) async {
    _selectedBackgroundColor = color;
    _prefs.setInt('selectedBackgroundColor', color.value);
    notifyListeners();
  }
}
