import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const redditOrange = Color.fromARGB(255, 255, 72, 0);
const redditBlack = Color(0x00000000);
const redditGrey = Color.fromRGBO(206, 227, 248, 1);
const redditBlue = Color.fromARGB(255, 1, 95, 167);

ThemeData spreadItTheme = ThemeData(
  fontFamily: GoogleFonts.notoSans().fontFamily,
   scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: redditOrange,
    primary: Colors.black,
    secondary: redditGrey,
    tertiary: redditBlue,
    surfaceTint: Colors.transparent,
  ),
);
