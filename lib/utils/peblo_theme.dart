import 'package:flutter/material.dart';

class PebloTheme {
  PebloTheme._();

  static const Color sunYellow    = Color(0xFFFFD94A);
  static const Color skyBlue      = Color(0xFF4FC3F7);
  static const Color leafGreen    = Color(0xFF66BB6A);
  static const Color coralRed     = Color(0xFFFF6B6B);
  static const Color deepPurple   = Color(0xFF5C35A8);
  static const Color midnightBlue = Color(0xFF1A1150);
  static const Color cloudWhite   = Color(0xFFF9F7FF);
  static const Color softLavender = Color(0xFFD4C5F9);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepPurple, midnightBlue],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    colors: [Color(0xFFFFD94A), Color(0xFFFF9F1C)],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
  );

  static TextStyle storyText(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontFamily: 'Nunito',
        fontSize: 18,
        height: 1.65,
        color: const Color(0xFF2D2D3A),
        fontWeight: FontWeight.w600,
      );

  static TextStyle questionText(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w800,
        color: const Color(0xFF2D2D3A),
        height: 1.4,
      );

  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? cloudWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: deepPurple,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Nunito',
      );
}
