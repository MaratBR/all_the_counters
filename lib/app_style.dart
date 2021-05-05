import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //#region light theme

  static final _primaryColor = 0xFF33da7c;

  static final swatch = MaterialColor(_primaryColor, <int, Color>{
    50: Color(0xFFd4f7e3),
    100: Color(0xFFbef3d5),
    200: Color(0xFF93ebb9),
    300: Color(0xFF75e6a6),
    400: Color(0xFF53df90),
    500: Color(_primaryColor),
    600: Color(0xFF24c268),
    700: Color(0xFF1c9751),
    800: Color(0xFF146c3a),
    900: Color(0xff072614),
  });

  //#endregion

  //#region dark theme

  static final darkCanvasColor = Color(0xFF131313);

  //#endregion
}