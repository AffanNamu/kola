import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/product/product_model.dart';
import '../../../../data/models/product/product_variant_model.dart';
import '../../../../data/remote/cloudinary/cloudinary_service.dart';
import '../../../../data/remote/firestore/admin_audit_firestore.dart';
import '../../../providers/category/category_provider.dart';
import '../../../providers/product/product_provider.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService.withClient();
});

class AdminAddProductScreen extends ConsumerStatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  ConsumerState<AdminAddProductScreen> createState() =>
      _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends ConsumerState<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _slug = TextEditingController();
  final _categoryId = TextEditingController();
  final _categoryName = TextEditingController();
  final _price = TextEditingController();
  final _comparePrice = TextEditingController();
  final _sku = TextEditingController();
  final _stock = TextEditingController(text: '0');
  final _description = TextEditingController();
  final _benefits = TextEditingController();
  final _ingredients = TextEditingController();
  final _howToUse = TextEditingController();

  bool _isFeatured = false;
  bool _isNewArrival = true;
  bool _isBestSeller = false;
  bool _isAvailable = true;

  final List<File> _localImages = [];
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    _categoryId.dispose();
    _categoryName.dispose();
    _price.dispose();
    _comparePrice.dispose();
    _sku.dispose();
    _stock.dispose();
    _description.dispose();
    _benefits.dispose();
    _ingredients.dispose();
    _howToUse.dispose();
    super.dispose();
  }

  String _makeSlug(String text) {
    final s = text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
    return s;
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;
    setState(() {
      _localImages.addAll(files.map((x) => File(x.path)));
    });
  }

  Future<List<String>> _uploadImages() async {
    final cloudinary = ref.read(cloudinaryServiceProvider);
    final urls = <String>[];
    for (final f in _localImages) {
      final url = await cloudinary.uploadImage(
        file: f,
        folder: CloudinaryService.productsFolder(),
      );
      urls.add(url);
    }
    return urls;
  }

  List<String> _splitLines(String text) {
    return text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _chooseCategoryDialog() async {
    final catsAsync = ref.read(activeCategoriesProvider);
    final cats = catsAsync.maybeWhen(data: (x) => x, orElse: () => []);
    if (cats.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No categories yet. Create categories first.')),
      );
      return;
    }

    final chosen = await showDialog<dynamic>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: cats.length,
            itemBuilder: (_, i) {
              final c = cats[i];
              return ListTile(
                title: Text(c.name),
                subtitle: Text(c.id),
                onTap: () => Navigator.pop(context, c),
              );
            },
          ),
        ),
      ),
    );

    if (chosen == null) return;
    setState(() {
      _categoryId.text = chosen.id;
      _categoryName.text = chosen.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_localImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product image.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final imageUrls = await _uploadImages();
      final price = double.parse(_price.text.trim());
      final compare = _comparePrice.text.trim().isEmpty
          ? null
          : double.tryParse(_comparePrice.text.trim());
      final stock = int.tryParse(_stock.text.trim()) ?? 0;

      final product = ProductModel(
        id: '',
        name: _name.text.trim(),
        slug: _slug.text.trim().isEmpty ? _makeSlug(_name.text) : _makeSlug(_slug.text),
        description: _description.text.trim(),
        howToUse: _howToUse.text.trim(),
        categoryId: _categoryId.text.trim(),
        categoryName: _categoryName.text.trim(),
        images: imageUrls,
        price: price,
        comparePrice: compare,
        sku: _sku.text.trim(),
        stock: stock,
        isAvailable: _isAvailable,
        isFeatured: _isFeatured,
        isNewArrival: _isNewArrival,
        isBestSeller: _isBestSeller,
        benefits: _splitLines(_benefits.text),
        ingredients: _splitLines(_ingredients.text),
        variants: [
          ProductVariantModel(
            id: 'default',
            productId: '',
            name: 'Default',
            price: price,
            comparePrice: compare,
            stock: stock,
            sku: _sku.text.trim(),
            isAvailable: _isAvailable,
            isPopular: true,
            attributes: const {'size': 'default'},
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(productRepositoryProvider);
      final (id, failure) = await repo.create(product);

      if (failure != null) throw Exception(failure.message);
      await const AdminAuditFirestore().log(action: 'product_created', targetUid: id, details: {'name': product.name, 'sku': product.sku});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product created successfully.')),
      );
      context.pop();
      context.push('/admin/products/$id/edit');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.addProduct)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            children: [
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Images', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final f in _localImages)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            child: Image.file(f, width: 84, height: 84, fit: BoxFit.cover),
                          ),
                        InkWell(
                          onTap: _loading ? null : _pickImages,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Card(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _name,
                        label: 'Product Name',
                        prefixIcon: Icons.inventory_2_outlined,
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _slug,
                        label: 'Slug (optional)',
                        prefixIcon: Icons.link,
                        hintText: 'premium-kolanut-grade-a',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _price,
                              label: 'Price',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              prefixIcon: Icons.attach_money,
                              validator: (v) {
                                final d = double.tryParse((v ?? '').trim());
                                if (d == null || d <= 0) return 'Valid price';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _comparePrice,
                              label: 'Compare Price (optional)',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              prefixIcon: Icons.price_change_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _sku,
                              label: 'SKU',
                              prefixIcon: Icons.qr_code_2_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _stock,
                              label: 'Stock',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.stacked_bar_chart_outlined,
                              validator: (v) {
                                final d = int.tryParse((v ?? '').trim());
                                if (d == null || d < 0) return 'Valid stock';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _categoryName,
                              label: 'Category Name',
                              prefixIcon: Icons.category_outlined,
                              validator: (v) =>
                                  (v ?? '').trim().isEmpty ? 'Category name required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _categoryId,
                              label: 'Category ID',
                              prefixIcon: Icons.tag_outlined,
                              validator: (v) =>
                                  (v ?? '').trim().isEmpty ? 'Category ID required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _loading ? null : _chooseCategoryDialog,
                          icon: const Icon(Icons.search),
                          label: const Text('Pick Category'),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppTextField(
                        controller: _description,
                        label: 'Description',
                        maxLines: 4,
                        prefixIcon: Icons.notes_outlined,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _benefits,
                        label: 'Benefits (one per line)',
                        maxLines: 4,
                        prefixIcon: Icons.check_circle_outline,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _ingredients,
                        label: 'Ingredients (one per line)',
                        maxLines: 4,
                        prefixIcon: Icons.grass_outlined,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _howToUse,
                        label: 'How to Use',
                        maxLines: 3,
                        prefixIcon: Icons.menu_book_outlined,
                      ),
                      const SizedBox(height: 12),
                      _SwitchRow(label: 'Available', value: _isAvailable, onChanged: (v) => setState(() => _isAvailable = v)),
                      _SwitchRow(label: 'Featured', value: _isFeatured, onChanged: (v) => setState(() => _isFeatured = v)),
                      _SwitchRow(label: 'New Arrival', value: _isNewArrival, onChanged: (v) => setState(() => _isNewArrival = v)),
                      _SwitchRow(label: 'Best Seller', value: _isBestSeller, onChanged: (v) => setState(() => _isBestSeller = v)),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Create Product',
                        onPressed: _loading ? null : _save,
                        isLoading: _loading,
                        icon: Icons.save_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
