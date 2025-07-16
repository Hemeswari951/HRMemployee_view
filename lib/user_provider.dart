import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _employeeId;

  String? get employeeId => _employeeId;

  void setEmployeeId(String id) {
    _employeeId = id;
    notifyListeners();
  }
}
