import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.height = 1});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: AppColors.divider,
    );
  }
}
