import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/banner/banner_model.dart';
import '../../../../data/remote/firestore/admin_audit_firestore.dart';
import '../../../../data/remote/cloudinary/cloudinary_service.dart';
import '../../../providers/product/product_provider.dart' show cloudinaryServiceProvider;
import '../../../providers/banner/banner_provider.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

class AdminAddBannerScreen extends ConsumerStatefulWidget {
  const AdminAddBannerScreen({super.key});

  @override
  ConsumerState<AdminAddBannerScreen> createState() => _AdminAddBannerScreenState();
}

class _AdminAddBannerScreenState extends ConsumerState<AdminAddBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _subtitle = TextEditingController();
  final _sort = TextEditingController(text: '0');

  File? _image;
  bool _loading = false;

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _sort.dispose();
    super.dispose();
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
        const SnackBar(content: Text('Select a banner image')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final cloudinary = ref.read(cloudinaryServiceProvider);
      final imageUrl = await cloudinary.uploadImage(
        file: _image!,
        folder: CloudinaryService.bannersFolder(),
      );

      final sortOrder = int.tryParse(_sort.text.trim()) ?? 0;

      final banner = BannerModel(
        id: '',
        title: _title.text.trim(),
        subtitle: _subtitle.text.trim(),
        imageUrl: imageUrl,
        isActive: true,
        sortOrder: sortOrder,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final fs = ref.read(bannerFirestoreProvider);
      await fs.create(banner);
      await const AdminAuditFirestore().log(action: 'banner_created', details: {'title': banner.title});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner created')),
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
      appBar: AppBar(title: const Text('Add Banner')),
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
                    Text('Banner Image',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            )),
                    const SizedBox(height: 10),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: _image == null
                            ? const Center(child: Icon(Icons.image_outlined, color: AppColors.textTertiary))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                                child: Image.file(_image!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _pickImage,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Select Image'),
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
                        controller: _title,
                        label: 'Title',
                        prefixIcon: Icons.title,
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Title required' : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _subtitle,
                        label: 'Subtitle',
                        prefixIcon: Icons.subtitles_outlined,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _sort,
                        label: 'Sort Order',
                        prefixIcon: Icons.sort,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Create Banner',
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
