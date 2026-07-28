import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/route_constants.dart';
import '../../providers/auth/auth_provider.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthProvider);
    final user = auth.currentUser;
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.emailVerification),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Icon(Icons.mark_email_read_outlined,
                      color: AppColors.primary, size: 40),
                ),
                const SizedBox(height: 14),
                Text(
                  AppStrings.emailVerificationSent,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () async {
                    await user?.reload();
                    final refreshed = fb.FirebaseAuth.instance.currentUser;
                    if (refreshed?.emailVerified == true) {
                      context.go(RouteConstants.home);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Not verified yet.')),
                      );
                    }
                  },
                  child: const Text('I Verified My Email'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => ref
                      .read(authControllerProvider.notifier)
                      .resendEmailVerification(),
                  child: const Text(AppStrings.resendVerification),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    context.go(RouteConstants.login);
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
