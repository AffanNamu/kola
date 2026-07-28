//app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors - Dark Forest Green
  static const Color primary = Color(0xFF2D5A27);
  static const Color primaryDark = Color(0xFF1A3A16);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primarySurface = Color(0xFFE8F5E9);

  // Secondary - Warm Gold/Amber (kolanut accent)
  static const Color secondary = Color(0xFFB8860B);
  static const Color secondaryLight = Color(0xFFD4A017);
  static const Color secondarySurface = Color(0xFFFFF8E1);

  // Background Colors - Warm Cream
  static const Color background = Color(0xFFF5F0E8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F4EC);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5A5A5A);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Order Status Colors
  static const Color statusPending = Color(0xFFF57C00);
  static const Color statusPaid = Color(0xFF1976D2);
  static const Color statusConfirmed = Color(0xFF7B1FA2);
  static const Color statusProcessing = Color(0xFFF57C00);
  static const Color statusPacked = Color(0xFF0097A7);
  static const Color statusShipped = Color(0xFF1976D2);
  static const Color statusDelivered = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFE53935);
  static const Color statusRefunded = Color(0xFF9E9E9E);

  // Border & Divider
  static const Color border = Color(0xFFE0D8CC);
  static const Color borderLight = Color(0xFFF0EAE0);
  static const Color divider = Color(0xFFEEE8DC);

  // Shadow
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Rating
  static const Color ratingActive = Color(0xFFFFC107);
  static const Color ratingInactive = Color(0xFFE0E0E0);

  // Skeleton/Shimmer
  static const Color shimmerBase = Color(0xFFEEE8DC);
  static const Color shimmerHighlight = Color(0xFFF8F4EC);

  // Transparent
  static const Color transparent = Colors.transparent;

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
}
