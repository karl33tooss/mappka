import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Main headers
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textMain,
  );

  // Simple input text
  static const TextStyle bodyInput = TextStyle(
    fontSize: 16,
    color: AppColors.textMain,
  );

  // Hint and Labels text
  static const TextStyle label = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  // Main buttons (ElevatedButton)
  static const TextStyle primaryButton = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Text buttons (TextButton)
  static const TextStyle textButton = TextStyle(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );
}