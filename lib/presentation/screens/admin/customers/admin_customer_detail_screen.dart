import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AdminCustomerDetailScreen extends StatelessWidget {
  const AdminCustomerDetailScreen({super.key, required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Customer Detail')),
      body: Center(child: Text('Customer: $customerId (next: profile + orders).')),
    );
  }
}
