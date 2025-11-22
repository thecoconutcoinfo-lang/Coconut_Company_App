import 'package:flutter/foundation.dart';

enum UserRole { admin, seller, none }

class UserProvider with ChangeNotifier {
  UserRole _userRole = UserRole.none;

  UserRole get userRole => _userRole;

  void setUserRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }
}
