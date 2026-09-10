import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Quản lý font chữ chuẩn Pixel Art (VT323) cho toàn bộ game
class GameTypography {
  GameTypography._();

  /// Tạo TextStyle với font Pixel VT323 hỗ trợ tiếng Việt đầy đủ và sắc nét
  static TextStyle pixel({
    Color? color,
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.normal,
    List<Shadow>? shadows,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.vt323(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      shadows: shadows,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}
