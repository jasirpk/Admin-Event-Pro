import 'package:flutter/material.dart';

Color myColor = Color(0xFF0CFCDF);
var sizedbox = SizedBox(height: 20);
var sizedboxWidth = SizedBox(width: 20);
Color myCustomColor = Color(0xFF840CFC);
var sizedBoxSmall = SizedBox(height: 10);

TextStyle myTextStyle(double screenHeight, Color myColor) {
  return TextStyle(
    fontSize: screenHeight,
    fontWeight: FontWeight.w500,
    color: myColor,
  );
}
