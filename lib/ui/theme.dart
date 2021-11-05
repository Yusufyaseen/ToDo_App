import 'dart:ui';

import 'package:flutter/material.dart';

const Color bluishClr = Color(0xFF4e5ae8);
const Color orangeClr = Color(0xff827717);
const Color pinkClr = Color(0xffb71c1c);
const Color white = Colors.white;
const Color primaryClr = Colors.deepPurple;
const Color darkGreyClr = Color(0xFF121212);
const Color darkHeaderClr = Color(0xFF424242);

class Themes {
  static final light = ThemeData(
    primaryColor: primaryClr,
    primarySwatch: Colors.deepPurple,
    backgroundColor: Colors.white,
    brightness: Brightness.light,
  );
  static final dark = ThemeData(
    primaryColor: darkGreyClr,
    backgroundColor: darkGreyClr,
    brightness: Brightness.dark,
  );
}
