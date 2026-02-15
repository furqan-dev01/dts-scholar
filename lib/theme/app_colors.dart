import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color deepBlue = Color(0xFF002366);
  static const Color maroon = Color(0xFF800000);

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color transparent = Colors.transparent;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepBlue, maroon],
    stops: [0.3, 0.9],
  );
}
