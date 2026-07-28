import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

@freezed
class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    required String id,
    required String productId,
    required String productName,
    required String productImage,
    required double price,
    required int quantity,
    String? variantId,
    @Default('') String variantName,
    @Default('') String sku,
    @Default(0) int maxStock,
    DateTime? addedAt,
  }) = _CartItemModel;

  const CartItemModel._();

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  double get total => price * quantity;

  bool get isAtMaxStock => maxStock > 0 && quantity >= maxStock;
}
