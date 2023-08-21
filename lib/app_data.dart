import 'package:flutter/material.dart';

class AppData {
  final int selectedMethodValue;

  AppData(this.selectedMethodValue);
}

class AppDataProvider with ChangeNotifier {
  AppData _appData = AppData(0); 

  int get selectedMethodValue => _appData.selectedMethodValue;

  void updateSelectedMethodValue(int newValue) {
    _appData = AppData(newValue);
    notifyListeners();
  }
  
}