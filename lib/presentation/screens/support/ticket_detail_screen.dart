import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Ticket #$ticketId')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            border: Border.all(color: AppColors.borderLight),
          ),
          // TODO: wire up to SupportProvider once ticket-detail is ready.
          child: Text('Ticket details for $ticketId will appear here.'),
        ),
      ),
    );
  }
}
