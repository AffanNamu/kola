import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/route_constants.dart';
import '../../providers/category/category_provider.dart';
import '../../widgets/category/category_card.dart';
import '../../widgets/common/app_empty_widget.dart';
import '../../widgets/common/app_error_widget.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(activeCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.shopByCategory)),
      body: SafeArea(
        child: catsAsync.when(
          data: (cats) {
            if (cats.isEmpty) {
              return const AppEmptyWidget(
                title: 'No categories yet',
                subtitle: 'Admin needs to add categories first.',
                icon: Icons.category_outlined,
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: cats.length,
              itemBuilder: (context, i) {
                final c = cats[i];
                final img = c.imageUrl.isNotEmpty ? c.imageUrl : c.iconUrl;

                return CategoryCard(
                  name: c.name,
                  imageUrl: img,
                  onTap: () {
                    final uri = Uri(
                      path: RouteConstants.shop,
                      queryParameters: {
                        'categoryId': c.id,
                        'categoryName': c.name,
                      },
                    );
                    context.go(uri.toString());
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorView(
            message: 'Failed to load categories.\n$e',
            onRetry: () => ref.refresh(activeCategoriesProvider),
          ),
        ),
      ),
    );
  }
}
