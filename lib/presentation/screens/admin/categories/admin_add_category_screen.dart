import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/category/category_model.dart';
import '../../../../data/remote/firestore/admin_audit_firestore.dart';
import '../../../../data/remote/cloudinary/cloudinary_service.dart';
import '../../../providers/product/product_provider.dart' show cloudinaryServiceProvider;
import '../../../providers/category/category_provider.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

class AdminAddCategoryScreen extends ConsumerStatefulWidget {
  const AdminAddCategoryScreen({super.key});

  @override
  ConsumerState<AdminAddCategoryScreen> createState() =>
      _AdminAddCategoryScreenState();
}

class _AdminAddCategoryScreenState extends ConsumerState<AdminAddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _slug = TextEditingController();
  final _description = TextEditingController();
  final _sortOrder = TextEditingController(text: '0');

  File? _image;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    _description.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  String _makeSlug(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    setState(() => _image = File(x.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category image/icon.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final cloudinary = ref.read(cloudinaryServiceProvider);
      final imageUrl = await cloudinary.uploadImage(
        file: _image!,
        folder: CloudinaryService.categoriesFolder(),
      );

      final sortOrder = int.tryParse(_sortOrder.text.trim()) ?? 0;

      final category = CategoryModel(
        id: '',
        name: _name.text.trim(),
        slug: _slug.text.trim().isEmpty ? _makeSlug(_name.text) : _makeSlug(_slug.text),
        description: _description.text.trim(),
        imageUrl: imageUrl,
        iconUrl: imageUrl,
        isActive: true,
        sortOrder: sortOrder,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(categoryRepositoryProvider);
      final (id, failure) = await repo.create(category);
      if (failure != null) throw Exception(failure.message);
      await const AdminAuditFirestore().log(action: 'category_created', targetUid: id, details: {'name': category.name});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category created: $id')),
      );
      Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Add Category')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingLG),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Image/Icon',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: _image == null
                              ? const Icon(Icons.image_outlined, color: AppColors.textTertiary)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                                  child: Image.file(_image!, fit: BoxFit.cover),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _loading ? null : _pickImage,
                            icon: const Icon(Icons.upload_file_outlined),
                            label: const Text('Select Image'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
                        controller: _name,
                        label: 'Category Name',
                        prefixIcon: Icons.category_outlined,
                        validator: (v) =>
                            (v ?? '').trim().isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _slug,
                        label: 'Slug (optional)',
                        prefixIcon: Icons.link,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _sortOrder,
                        label: 'Sort Order',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.sort,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _description,
                        label: 'Description',
                        maxLines: 3,
                        prefixIcon: Icons.notes_outlined,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Create Category',
                        icon: Icons.save_outlined,
                        onPressed: _loading ? null : _save,
                        isLoading: _loading,
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
