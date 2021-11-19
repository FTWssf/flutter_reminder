import 'package:flutter/material.dart';

class Constant {
  // app related
  static const String appName = '油棕';
  static const String androidIcon = 'app_icon';

  // logic related
  static const int harvestDay = 14;
  // database related
  static const String dbFileName = 'local.db';
  static const int dbCurrentVersion = 1;
  static const int row = 10;

  // design related
  static const String theme = 'AppTheme';
  static const String locale = 'locale';

  // font size
  static const double toastFontSize = 16;
  static const double textFormFontSize = 25;
  static const double textFormErrorFontSize = 15;

  static final Map<int, Color> _amberColorMap = {
    50: Color(0xFFFFD7C2),
    100: Colors.amber[100] ?? Colors.amber,
    200: Colors.amber[200] ?? Colors.amber,
    300: Colors.amber[300] ?? Colors.amber,
    400: Colors.amber[400] ?? Colors.amber,
    500: Colors.amber[500] ?? Colors.amber,
    600: Colors.amber[600] ?? Colors.amber,
    700: Colors.amber[800] ?? Colors.amber,
    800: Colors.amber[900] ?? Colors.amber,
    900: Colors.amber[700] ?? Colors.amber,
  };
  static final MaterialColor themeColor =
      MaterialColor(Colors.amber[300]!.value, _amberColorMap);
}
