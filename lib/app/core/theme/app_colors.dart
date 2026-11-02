import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand BEM Dakar
  static const primary = Color(0xFFCC0000);
  static const primaryDark = Color(0xFF990000);
  static const primaryLight = Color(0xFFFFE5E5);

  // Surfaces
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF666666);
  static const divider = Color(0xFFE0E0E0);

  // Statuts
  static const statusOuverte = Color(0xFF1565C0);
  static const statusEnCours = Color(0xFFE65100);
  static const statusResolue = Color(0xFF2E7D32);
  static const statusRejetee = Color(0xFF757575);

  // Priorités
  static const priorityBasse = Color(0xFF90A4AE);
  static const priorityNormale = Color(0xFF42A5F5);
  static const priorityHaute = Color(0xFFFFA726);
  static const priorityUrgente = Color(0xFFEF5350);
}
