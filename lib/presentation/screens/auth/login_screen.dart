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

  Future<void> _signInGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    ref.read(authControllerProvider).whenOrNull(
      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(e))),
      ),
    );
  }

  Future<void> _continueAsGuest() async {
    await ref.read(authControllerProvider.notifier).signInAnonymously();
    if (!mounted) return;
    ref.read(authControllerProvider).whenOrNull(
      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(e))),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signInEmail(
          _email.text.trim().toLowerCase(),
          _password.text,
        );

    if (!mounted) return;
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
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.borderLight)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'OR CONTINUE WITH',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                  ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.borderLight)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: isLoading ? null : _signInGoogle,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF202124),
                            side: BorderSide(color: AppColors.borderLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F3F4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF4285F4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: TextButton.icon(
                          onPressed: isLoading ? null : _continueAsGuest,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            backgroundColor: AppColors.primary.withOpacity(0.07),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.storefront_outlined),
                          label: const Text(
                            'Continue as Guest',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Browse products and add to cart. Sign up when you are ready to pay.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
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
