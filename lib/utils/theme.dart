import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_editor_app/utils/constants.dart';

ThemeData myTheme() => ThemeData(
  brightness: Brightness.dark,
  primaryColor: kPrimaryColor,

  textTheme: TextTheme(
    headline6: GoogleFonts.manrope(
      fontSize: mediumTextSize,
      color: Colors.white,
    ),
    headline4: GoogleFonts.manrope(
      fontSize: largeTextSize,
      color: Colors.white,
    ),
    subtitle1: GoogleFonts.manrope(
      fontSize: subtitle1TextSize,
      color: Colors.white,
    ),
    bodyText1: GoogleFonts.manrope(
      fontSize: bodyText1TextSize,
      color: Colors.white60,
    ),
  ),
  iconTheme: const IconThemeData(
    color: Colors.white,
    opacity: 0.8,
  ),
);