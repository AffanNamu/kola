import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/route_constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signInEmail(
          _email.text.trim().toLowerCase(),
          _password.text,
        );

    final state = ref.read(authControllerProvider);
    state.whenOrNull(
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(e))),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAction = ref.watch(authControllerProvider);
    final isLoading = authAction.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Icon(Icons.eco, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                AppStrings.signIn,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Welcome back. Shop premium natural products.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingLG),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _email,
                        label: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) {
                          final x = (v ?? '').trim();
                          if (x.isEmpty) return 'Email is required';
                          if (!x.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _password,
                        label: AppStrings.password,
                        obscureText: _obscure,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () => setState(() => _obscure = !_obscure),
                        validator: (v) {
                          if ((v ?? '').isEmpty) return 'Password is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push(RouteConstants.forgotPassword),
                          child: const Text(AppStrings.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppButton(
                        label: AppStrings.signIn,
                        onPressed: _submit,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .signInAnonymously();
                                if (!mounted) return;
                                final result = ref.read(authControllerProvider);
                                result.whenOrNull(
                                  error: (e, _) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(authErrorMessage(e))),
                                    );
                                  },
                                );
                              },
                        child: const Text(AppStrings.continueAsGuest),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.dontHaveAccount,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RouteConstants.register),
                    child: const Text(AppStrings.signUp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
