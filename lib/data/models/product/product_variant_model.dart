import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_variant_model.freezed.dart';
part 'product_variant_model.g.dart';

@freezed
class ProductVariantModel with _$ProductVariantModel {
  const factory ProductVariantModel({
    required String id,
    required String productId,
    required String name,
    required double price,
    double? comparePrice,
    @Default(0) int stock,
    @Default('') String sku,
    @Default(true) bool isAvailable,
    @Default(false) bool isPopular,
    @Default({}) Map<String, dynamic> attributes,
  }) = _ProductVariantModel;

  const ProductVariantModel._();

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantModelFromJson(json);

  bool get isOnSale =>
      comparePrice != null && comparePrice! > price;

  bool get isInStock => stock > 0 && isAvailable;

  double get discountPercentage {
    if (!isOnSale) return 0;
    return ((comparePrice! - price) / comparePrice! * 100).roundToDouble();
  }
}
