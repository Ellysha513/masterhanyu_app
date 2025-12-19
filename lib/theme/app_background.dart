import 'package:flutter/material.dart';

BoxDecoration masterHanyuBackground() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFEDE7FF),
        Color(0xFFFDFBFF),
      ],
    ),
  );
}
