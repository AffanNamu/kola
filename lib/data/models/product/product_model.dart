import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_variant_model.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String slug,
    @Default('') String description,
    @Default('') String howToUse,
    required String categoryId,
    @Default('') String categoryName,
    @Default([]) List<String> images,
    required double price,
    double? comparePrice,
    @Default('') String sku,
    @Default(0) int stock,
    @Default(0) int reservedStock,
    @Default(0) int soldCount,
    @Default(true) bool isAvailable,
    @Default(false) bool isFeatured,
    @Default(false) bool isNewArrival,
    @Default(false) bool isBestSeller,
    @Default(false) bool isDeleted,
    @Default([]) List<String> tags,
    @Default([]) List<String> benefits,
    @Default([]) List<String> ingredients,
    @Default([]) List<ProductVariantModel> variants,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @Default('') String weight,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _ProductModel;

  const ProductModel._();

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromJson({
      'id': doc.id,
      ...data,
      'price': (data['price'] as num?)?.toDouble() ?? 0.0,
      'comparePrice': (data['comparePrice'] as num?)?.toDouble(),
      'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'updatedAt':
          (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    if (createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    if (updatedAt != null) {
      json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }
    return json;
  }

  bool get isOnSale =>
      comparePrice != null && comparePrice! > price;

  double get discountPercentage {
    if (!isOnSale) return 0;
    return ((comparePrice! - price) / comparePrice! * 100).roundToDouble();
  }

  bool get isInStock => stock > 0 && isAvailable;

  bool get isLowStock => stock > 0 && stock <= 5;

  String get thumbnailUrl => images.isNotEmpty ? images.first : '';

  String get stockStatus {
    if (!isAvailable || stock == 0) return 'out_of_stock';
    if (stock <= 5) return 'low_stock';
    return 'in_stock';
  }

  int get availableStock => stock - reservedStock;
}
