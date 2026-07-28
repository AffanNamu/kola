import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AdminAddCouponScreen extends StatelessWidget {
  const AdminAddCouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Coupon')),
      body: const Center(child: Text('Next: coupon form + Firestore save.')),
    );
  }
}
