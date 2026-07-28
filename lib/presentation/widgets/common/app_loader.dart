import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 26});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppColors.primary,
      ),
    );
  }
}
