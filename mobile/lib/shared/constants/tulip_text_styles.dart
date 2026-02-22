import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tulip_colors.dart';

class TulipTextStyles {
  static TextStyle get heading1 => GoogleFonts.cormorantGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: TulipColors.brown,
      );

  static TextStyle get heading2 => GoogleFonts.cormorantGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: TulipColors.brown,
      );

  static TextStyle get heading3 => GoogleFonts.cormorantGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: TulipColors.brown,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: TulipColors.brown,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TulipColors.brownLight,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TulipColors.brownLighter,
      );

  static TextStyle get button => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get label => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TulipColors.brown,
      );
}
